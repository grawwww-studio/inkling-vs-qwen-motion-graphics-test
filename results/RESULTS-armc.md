Public copy: internal file references removed; numbers unchanged.

# EP12 duel, arm C: Qwen3.8-27B with thinking OFF (run 2026-11-23)

**Arm C was added after the first result was known (the rule was written in our brief file, section "Post-hoc arm C", before this run). It is exploratory. It does not replace or re-label the headline comparison in RESULTS.md.** Nothing else was added after it.

## Arm C numbers (graded blind, n = 20)
| | Value |
|---|---|
| Pass (R1-R3) | **13 / 20 (65 %)** |
| Rendered an mp4 (R1) | 19 / 20 (1 attempt: 3 rounds of `hf check` errors, no mp4 = R1 fail by rule; no attempt hit the 20k cap) |
| Pass among rendered | 13 / 19 |
| Per brief B1 / B2 / B3 / B4 / B5 | 0, 4, 2, 4, 3 (of 4 each) |
| Fix rounds used (total, max 2 per attempt) | 8 (s1 B2: 2, s1 B4: 1, s2 B1: 2, s3 B1: 2, s4 B1: 1) |
| Wall per attempt, mean / median | 62 s / 59 s (total 1,241 s = 0.34 h for 20 attempts; whole job 1,369 s incl. sha256 check and 4 model loads) |
| Output tokens per attempt, mean / median | 2016 / 1912 (min 648, max 5710) |
| Peak VRAM, whole card, ctx 32k, q8_0 KV | 20,626 MiB (20.1 GiB) by the grader's `nvidia-smi` sampler every 5 s (`vram_armc.csv`, 271 samples); 20,606 MiB (20.1 GiB) by the ledger's 2 s samples |
| Generation speed from server logs | see "Throughput and runtime" |
| Ledger job | `ep12-armc-20261123T003801Z`, 00:38:01-01:00:50Z, rc 0, 82.0 Wh, peak 281 W, mean util 71 %, whole card |

Thinking was verified off before the first attempt: probe request with `chat_template_kwargs {"enable_thinking": false}` returned `reasoning_content: None` (`armc_probe.json`), and none of the 28 model calls has a `[REASONING]` block (`renders/qwennothink_s*/*/llm_round*.txt`). Runner flag: `NOTHINK=1` already existed in `runner.py` (passes `enable_thinking=false`); `runner.py` is unchanged (no diff, no .bak needed); without the variable the request body is the old one.

Setup identical to the duel except thinking: same blob `Qwen3.8-27B-Q4_K_M.main-d15d4b6d.gguf` (sha256 d15d4b6de55f...a48ee re-verified at job start), llama.cpp b12631 Vulkan, `-c 32768 -ngl 99 -fa on --cache-type-k q8_0 --cache-type-v q8_0 --parallel 1 --threads 4 --jinja`, seeds 1-4, temperature 0.6, top_p 0.95, 20,000-token cap per call, up to 2 fix rounds, same scaffold, HyperFrames 0.8.176. Script: `armc.sh`. Port 11497. Blocks ran seed 1, 2, 3, 4 in order, no interruption, nothing resumed.

## Three-column table (columns 1-2 copied unchanged from the current RESULTS.md)
| | Inkling 2 Mini IQ4_NL | Qwen3.8-27B Q4_K_M, thinking on | Qwen3.8-27B Q4_K_M, thinking off (added after the first result; exploratory) |
|---|---|---|---|
| Pass (R1-R3) | **17 / 20 (85 %)** | **13 / 20 (65 %)** | 13 / 20 (65 %) |
| Rendered an mp4 (R1) | 20 / 20 | 15 / 20 (5 attempts never produced HTML: every round hit the 20k output cap) | 19 / 20 (1 no mp4: 3 rounds of check errors) |
| Pass among rendered | 17 / 20 | 13 / 15 | 13 / 19 |
| Per brief B1 / B2 / B3 / B4 / B5 | 3, 4, 4, 4, 2 | 0, 4, 3, 4, 2 | 0, 4, 2, 4, 3 |
| Fix rounds used (total) | 2 | 18 | 8 |
| Wall per attempt, mean / median | 210 s / 193 s | 850 s / 780 s | 62 s / 59 s |
| Output tokens per attempt, mean / median | 12176 / 11146 | 32045 / 29321 (exact median 29320.5) | 2016 / 1912 |
| Total wall (20 attempts) | 1.16 h | 4.72 h | 0.34 h |
| Peak VRAM (whole card, ctx 32k, q8_0 KV) | 21,824 MiB (21.3 GiB), sampled in the resume run only | 20,640 MiB (20.2 GiB), one sampled peak, resume run only | 20,626 MiB (20.1 GiB), 5 s sampler over the whole run |

## Blind grading (before the mapping was opened)
- `blind_pack_armc.py` built `blind_armc/`: 31 sheets under shuffled ids Y01-Y31 = 19 arm C sheets (the 20th has no mp4) + 12 decoys (6 Inkling + 6 Qwen-thinking sheets from the first run, drawn with `random.Random(2311)` from the graded attempts, copied under new ids). Same 9-frame rule as `blind_pack.py`. Mapping: `SEALED-mapping-armc.json`.
- The grader (an AI agent, the same one that ran the harness) graded every sheet by R1-R3 (brief id visible, model not): `blind_verdicts_armc.json`, identical copy `blind_verdicts_armc.json.locked`.
- **Clock times (`date -u`): verdicts locked 2026-11-23T01:01:47Z; mapping first opened 2026-11-23T01:01:48Z** (same shell command, lock first). The mapping file itself was written at pack time (01:01Z, before grading) and not read until then.
- **Decoy agreement with the first-run verdicts: 12 / 12 same verdict. Flipped decoys: none.** (Notes were not compared word for word; the verdict word is the figure.)
- Subjective: layout and text judgements from 9 frames per attempt, not from watching clips; 9 frames cannot show mid-clip glitches.

## Failures (7 of 20 attempts, none passes)
- s1 B1 (Y26): "LOCALAI," space lost, the word REAL missing from the frame.
- s2 B1: no mp4; `hf check` errors (text-box overflow) in all 3 rounds (finish=stop each time, 2,701 output tokens in total over the 3 rounds, not the cap). R1 fail by rule.
- s3 B1 (Y29): band empty and the word REAL missing, "LOCAL   AI," gap. (Rendered after 2 fix rounds.)
- s4 B1 (Y16): REAL set in white on the yellow band, unreadable, last L spills out of the band.
- s1 B3 (Y27): bars not proportional to the values (42 vs 51 vs 23 bar lengths inconsistent).
- s2 B3 (Y18): the value label "58" missing in the yellow band at the hold frame.
- s4 B5 (Y25): logo horizontally squeezed; first chip has no icon.

## Best and worst renders (same mechanical rule as RESULTS.md: best = PASS with 0 fix rounds, shortest wall; worst = FAIL, longest wall)
Best:
  - renders/qwennothink_s2/B4/B4.mp4 (B4, 24.4 s)
  - renders/qwennothink_s3/B4/B4.mp4 (B4, 24.6 s)
  - renders/qwennothink_s4/B4/B4.mp4 (B4, 25.4 s)
Worst:
  - renders/qwennothink_s3/B1/ (B1, 85.1 s) - band empty, REAL missing
  - renders/qwennothink_s2/B1/ (B1, 76.9 s) - no mp4, check errors in 3 rounds
  - renders/qwennothink_s4/B5/ (B5, 63.9 s) - logo squeezed

## Throughput and runtime (data already on disk, no new runs)
(a) Generation speed from the llama-server `print_timing` lines (`eval time ... tokens per second`), per request:
| Arm | requests covered | generation tok/s median (range) | prompt-eval tok/s median (range) |
|---|---|---|---|
| Inkling 2 Mini (`server_inkling_s1-4.log`) | 22 | 61.3 (59.7-62.1) | 339 (210-1,346) |
| Qwen thinking on (`server_qwen_s1-4.log`) | 34 | 38.1 (37.9-38.8) | 279 (62-1,774) |
| Qwen thinking off (`server_qwennothink_s1-4.log`) | 29 (28 attempt calls + 1 probe request) | 39.0 (20.2-39.3) | 294 (25-1,422) |
Prompt-eval speed varies with how much of the prompt was served from the prompt cache; the low arm C generation minimum (20.2) belongs to a very short request (a few tokens, where the timing is dominated by start-up), not isolated further.
(b) Why llama.cpp Vulkan on an NVIDIA card and not a CUDA build: reason not recorded. Our notes record only the fact: "Only llama.cpp Vulkan b10883 exists ; no vLLM, no CUDA build", that the Inkling model needed upstream b12631 Vulkan because the pinned build 10883 does not know it, and 14 Xid 109 events on llama-server (Vulkan) before 16-Oct. None says why Vulkan was chosen over CUDA.

## Not measured
Thinking-budget variants, reruns, other seeds (excluded by the brief); per-request energy; cost in rented-GPU terms; any significance test on arm C (n = 20; 13/20 equals the thinking-on arm's 13/20).

## Files
`RESULTS-armc.md`, `results_armc.json`, `results_armc.jsonl`, `armc.sh`, `blind_pack_armc.py`, `blind_armc/` (Y01-Y31 sheets), `SEALED-mapping-armc.json`, `blind_verdicts_armc.json` (+ `.locked`), `renders/qwennothink_s<seed>/<brief>/`, `server_qwennothink_s1-4.log`, `vram_armc.csv`, `armc_probe.json`. No existing duel file was modified.

## Verifier pass (2026-11-23T01:05Z, recomputed from results_armc.jsonl, log.json, blind_verdicts_armc.json, both mappings, server logs, vram_armc.csv)
Confirmed: 13/20 passed; 19/20 rendered (s2 B1: three replies ending normally with check errors, no token-limit stop anywhere in arm C); per brief 0, 4, 2, 4, 3; 8 fix rounds, every one triggered by a check error; wall 62.05 s mean / 58.80 s median, 1,240.9 s for the 20 attempts; output tokens 2,015.95 mean / 1,911.5 median; thinking off in all 28 calls; the seven failures and their notes; decoys 12 of 12 with the first-run verdict; verdict file and locked copy identical; generation medians 61.30 / 38.09 / 38.98 tok/s (the 20.2 minimum is the 4-token probe request); peak 20,626 MiB. The mapping's "first opened" time rests on file access time (weak evidence) plus the grader's statement. Not checked: the "worst renders" list.
Derived: mean wall per attempt Inkling / Qwen thinking off = 3.38; Qwen thinking on / off = 13.7; Qwen title card (B1) across both Qwen arms = 0 of 8; two-sided Fisher exact 17/20 vs 13/20 p = 0.2733; rendered 20/20 vs 19/20 p = 1.00.
