#!/usr/bin/env bash
# EP12 arm C (post-hoc, exploratory): same Qwen3.8-27B blob, thinking OFF (NOTHINK=1 -> chat_template_kwargs enable_thinking=false in runner.py).
# Ran under our GPU job scheduler. Resumable: attempts with log.json are skipped. New names only; no duel file is touched.
set -uo pipefail
D="$(cd "$(dirname "$0")" && pwd)"; cd "$D"
BIN="${LLAMA_BIN:-llamacpp-b12631-vulkan/llama-b12631}"; export LD_LIBRARY_PATH="$BIN"
QM="${QWEN_GGUF:-models/Qwen3.8-27B-Q4_K_M.main-d15d4b6d.gguf}"
QSHA=d15d4b6de55f662ac40e867702d31afe738d032fa06b829b2b1a21a49d4a48ee
PORT=11497
echo "armc start $(date -u +%FT%TZ)"
got=$(sha256sum "$QM" | cut -d' ' -f1); echo "qwen sha256 $got"
[ "$got" = "$QSHA" ] || { echo "SHA MISMATCH"; exit 3; }
nvidia-smi -l 5 --query-gpu=timestamp,memory.used --format=csv,noheader -f "$D/vram_armc.csv" & SP=$!
LP=0
stop_server(){ [ "$LP" != 0 ] && { kill $LP 2>/dev/null; wait $LP 2>/dev/null; }; LP=0; }
trap 'stop_server; kill $SP 2>/dev/null' EXIT
for SEED in 1 2 3 4; do
  RUNS="renders/qwennothink_s${SEED}"
  todo=""; for B in B1 B2 B3 B4 B5; do [ -f "$D/$RUNS/$B/log.json" ] || todo="$todo $B"; done
  [ -z "$todo" ] && { echo "skip s$SEED (done)"; continue; }
  echo "== block s$SEED start $(date -u +%T), todo:$todo"
  "$BIN/llama-server" -m "$QM" --host localhost --port $PORT -c 32768 -ngl 99 -fa on --cache-type-k q8_0 --cache-type-v q8_0 --parallel 1 --threads 4 --jinja --no-webui > "$D/server_qwennothink_s${SEED}.log" 2>&1 &
  LP=$!
  curl -sf --retry 300 --retry-delay 3 --retry-connrefused --retry-all-errors -m 3 http://localhost:$PORT/health > /dev/null || { echo "server s$SEED did not start"; tail -5 "$D/server_qwennothink_s${SEED}.log"; stop_server; continue; }
  if [ "$SEED" = 1 ] || [ ! -f "$D/armc_probe.json" ]; then
    curl -s http://localhost:$PORT/v1/chat/completions -H 'Content-Type: application/json' -d '{"model":"qwen","messages":[{"role":"user","content":"Say hi in three words."}],"max_tokens":300,"temperature":0.6,"top_p":0.95,"chat_template_kwargs":{"enable_thinking":false}}' > "$D/armc_probe.json"
    python3 -I -c "import json,sys; m=json.load(open('$D/armc_probe.json'))['choices'][0]['message']; print('probe reasoning_content:', repr(m.get('reasoning_content'))[:80], 'content:', repr(m.get('content'))[:80]); sys.exit(1 if m.get('reasoning_content') else 0)" || { echo "THINKING NOT OFF: abort"; exit 4; }
  fi
  for B in $todo; do
    NOTHINK=1 QPORT=$PORT SEED=$SEED RUNS=$RUNS MODEL_LABEL=qwennothink VERBOSE=1 python3 -I "$D/runner.py" $B 2>&1 | tee -a "$D/run_armc.log" | grep '^{' >> "$D/results_armc.jsonl"
  done
  stop_server
  echo "== block s$SEED end $(date -u +%T)"
done
echo "armc done $(date -u +%FT%TZ)"
