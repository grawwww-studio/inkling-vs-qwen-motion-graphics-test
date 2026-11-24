#!/usr/bin/env bash
# EP12 duel: Inkling 2 Mini IQ4_NL vs stock Qwen3.8-27B Q4_K_M, 5 HyperFrames briefs x seeds 1-4 each (20 attempts per model).
# Ran under our GPU job scheduler. Blocks alternate Inkling, Qwen (one model on the card at a time). Resumable: finished attempts (log.json) are skipped.
# Usage: duel.sh <pid of the Qwen download curl, or 0>
set -uo pipefail
DLPID="${1:-0}"
D="$(cd "$(dirname "$0")" && pwd)"; cd "$D"
BIN="${LLAMA_BIN:-llamacpp-b12631-vulkan/llama-b12631}"; export LD_LIBRARY_PATH="$BIN"
IM="${INKLING_GGUF:-models/Inkling-2-Mini-IQ4_NL.gguf}"
QM="${QWEN_GGUF:-models/Qwen3.8-27B-Q4_K_M.main-d15d4b6d.gguf}"
QSHA=d15d4b6de55f662ac40e867702d31afe738d032fa06b829b2b1a21a49d4a48ee
PORT=11497
nvidia-smi -l 5 --query-gpu=timestamp,memory.used --format=csv,noheader -f "$D/vram.csv" & SP=$!
echo $SP > "$D/sampler.pid"
LP=0
stop_server(){ [ "$LP" != 0 ] && { kill $LP 2>/dev/null; wait $LP 2>/dev/null; }; LP=0; }
trap 'stop_server; kill $SP 2>/dev/null' EXIT
echo "duel start $(date -u +%FT%TZ)"
for PASS in 1 2; do
for blk in "inkling 1" "qwen 1" "inkling 2" "qwen 2" "inkling 3" "qwen 3" "inkling 4" "qwen 4"; do
  set -- $blk; MODEL=$1; SEED=$2
  RUNS="renders/${MODEL}_s${SEED}"
  todo=""; for B in B1 B2 B3 B4 B5; do [ -f "$D/$RUNS/$B/log.json" ] || todo="$todo $B"; done
  [ -z "$todo" ] && { echo "skip $blk (done)"; continue; }
  if [ $MODEL = qwen ]; then
    M=$QM
    if [ $PASS = 1 ] && [ ! -f "$D/qwen.sha.ok" ] && [ "$DLPID" != 0 ] && kill -0 $DLPID 2>/dev/null; then echo "defer $blk (Qwen download still running)"; continue; fi
    if [ ! -f "$D/qwen.sha.ok" ]; then
      [ "${1:-}" != "" ] || true
      [ "$DLPID" != 0 ] && tail --pid=$DLPID -f /dev/null
      got=$(sha256sum "$M" | cut -d' ' -f1); echo "qwen sha256 $got"
      [ "$got" = "$QSHA" ] || { echo "QWEN SHA MISMATCH, abort Qwen blocks"; exit 3; }
      echo "$got" > "$D/qwen.sha.ok"
    fi
  else M=$IM; fi
  echo "== block $blk start $(date -u +%T), todo:$todo"
  "$BIN/llama-server" -m "$M" --host localhost --port $PORT -c 32768 -ngl 99 -fa on --cache-type-k q8_0 --cache-type-v q8_0 --parallel 1 --threads 4 --jinja --no-webui > "$D/server_${MODEL}_s${SEED}.log" 2>&1 &
  LP=$!
  curl -sf --retry 300 --retry-delay 3 --retry-connrefused --retry-all-errors -m 3 http://localhost:$PORT/health > /dev/null || { echo "server for $blk did not start"; tail -5 "$D/server_${MODEL}_s${SEED}.log"; stop_server; continue; }
  curl -s http://localhost:$PORT/v1/models > "$D/v1_models_${MODEL}.json"
  for B in $todo; do
    QPORT=$PORT SEED=$SEED RUNS=$RUNS MODEL_LABEL=$MODEL VERBOSE=1 python3 -I "$D/runner.py" $B 2>&1 | tee -a "$D/run.log" | grep '^{' >> "$D/results.jsonl"
  done
  stop_server
  echo "== block $blk end $(date -u +%T)"
done
done
echo "duel done $(date -u +%FT%TZ)"
