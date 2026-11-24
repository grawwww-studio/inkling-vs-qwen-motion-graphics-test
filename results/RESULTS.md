Public copy: internal file references removed; numbers unchanged.

# EP12 duel: Inkling 2 Mini vs stock Qwen3.8-27B, HyperFrames, 20 attempts each (2026-11-22)

## Headline (graded blind, n = 20 per model)
| | Inkling 2 Mini IQ4_NL | Qwen3.8-27B Q4_K_M (current ggml-org main) |
|---|---|---|
| Pass (R1-R3, EP05 rubric) | **17 / 20 (85 %)** | **13 / 20 (65 %)** |
| Rendered an mp4 (R1) | 20 / 20 | 15 / 20 (5 attempts never produced HTML: every round hit the 20k output cap) |
| Pass among rendered | 17 / 20 | 13 / 15 |
| Per brief B1 / B2 / B3 / B4 / B5 | 3, 4, 4, 4, 2 (of 4 each) | 0, 4, 3, 4, 2 (of 4 each) |
| Fix rounds used (total, max 2 per attempt) | 2 | 18 |
| Wall per attempt, mean / median | 210 s / 193 s | 850 s / 780 s |
| Output tokens per attempt, mean / median | 12176 / 11146 | 32045 / 29321 (exact median 29320.5) |
| Total wall (20 attempts) | 1.16 h | 4.72 h |
| Peak VRAM (whole card, ctx 32k, q8_0 KV; sampled in the resume run only, `vram.csv`) | 21,824 MiB (21.3 GiB) | 20,640 MiB (20.2 GiB), one sampled peak; most samples 20,589-20,592 MiB. First run (before the kill): no data |

The 17/20 vs 13/20 gap is **not statistically significant** (Fisher exact p = 0.27); the robust differences are speed (about 4x faster per attempt, 210 s vs 850 s mean) and fewer thinking-cap failures (0 vs 5). n = 20 per model, 5 briefs x 4 seeds: indicative only.
Seeds are 1-4 (EP05 used an unseeded pilot plus seeds 1-3). Same sampler for both: temperature 0.6, top_p 0.95, 20,000-token cap per model call (up to 3 calls per attempt: draft + 2 fix rounds), reasoning ON at each model's default (Inkling: reasoning effort high; Qwen: thinking on).

## Setup (identical for both)
- Runtime: upstream llama.cpp b12631 Vulkan (`llamacpp-b12631-vulkan/llama-b12631`), `-c 32768 -ngl 99 -fa on --cache-type-k q8_0 --cache-type-v q8_0 --parallel 1 --jinja`, one model on the card at a time.
- Inkling: `ggml-org/Inkling-2-Mini-GGUF` IQ4_NL (17.63 GB, sha256 cbdf3fa9...2a81af4 verified). Qwen: `ggml-org/Qwen3.8-27B-GGUF` Q4_K_M, current main blob (sha256 d15d4b6d...a48ee, verified).
- Harness, scaffold, briefs and pass rules: copied unchanged from our episode 5 run, HyperFrames 0.8.176 pinned, CPU render; briefs and R1-R4 in `briefs.md`.
- Ledger jobs: `ep12-duel-20261122T135249Z` (13:52-15:08Z, killed, 273 Wh) and `ep12-duel-b-20261122T150903Z` (15:09-19:58Z, rc 0, 1,222 Wh, 90 % mean util, card peak 21,821 MiB). Resume run raised to a 14 G memory cap.

## Grading (blind)
`blind_pack.py` made one 9-frame contact sheet per rendered attempt under anonymous ids X01-X35 (shuffled, seed 12; frames are evenly spaced plus one frame 0.125 s before the end), mapping in `SEALED-mapping.json`. The grader (an AI agent, the same one that ran the harness) graded each sheet by R1-R3 (verdicts and notes in `blind_verdicts.json`, copy `.locked`, written before opening the mapping), then unblinded. Subjective parts: layout and text judgements from 9 frames, not from watching the clip. R1 durations were all within 0.3 s (ffprobe). The 5 attempts with no mp4 are R1 fails by rule and were not shown. The brief id was visible to the grader (the rubric needs it); the model was not.
Failures after render (5 of 35 renders): Inkling 3 (B1 "LOCALAI," with the space lost, seed 3; B5 logo squeezed and overlapping a band, seed 1; B5 logo scaled off-canvas, seed 2); Qwen 2 (B1 "LOCALAI," with the space lost, seeds 1 and 4, seed 1 also with the L of REAL clipped by the band).

## Caveats
- **Interleaving was disturbed.** Block order planned: Inkling s1, Qwen s1, Inkling s2, Qwen s2, ... The Qwen download was still running, so Qwen s1 was deferred; actual order: Inkling s1, Inkling s2, Qwen s2 (killed part-way by a cgroup out-of-memory kill: the job runner's default 6 GB MemoryMax vs llama-server 5.7 GB + 1 GB shmem + the headless Chromium render), then after the resume Qwen s1, Qwen s2 (rest), Inkling s3, Qwen s3, Inkling s4, Qwen s4. Blocks were alternated at seed level, not at attempt level, so model reloads stay few. The two Qwen s2 attempts finished before the kill were kept.
- **Not the same Qwen blob as EP05.** EP05's 9/20 (45 %) was on the older blob c600de03... (ggml-org revision of 2026-10-19) with thinking OFF (no-think); this duel uses the current main blob d15d4b6d... with thinking ON. The two Qwen numbers are not comparable.
- Qwen thinking runs: 5 of 20 attempts ran out of the 20k cap in all 3 rounds with no HTML, the same failure as EP05's think-mode B3. A thinking budget would likely lift Qwen; not tested (the brief fixed the cap for fairness).
- Cost estimate not computed (no rented-GPU price asked for).

## Best and worst renders for the episode (rule: best = PASS with 0 fix rounds, shortest wall; worst = FAIL, longest wall; not a taste pick, see contact sheets in `blind/`)
Inkling best:
  - renders/inkling_s1/B4/B4.mp4 (B4, 60 s)
  - renders/inkling_s2/B4/B4.mp4 (B4, 79 s)
  - renders/inkling_s4/B4/B4.mp4 (B4, 84 s)
Inkling worst:
  - renders/inkling_s2/B5/ (B5, 235 s) — logo scaled far larger than the canvas, GRAWWW cut off at bo
  - renders/inkling_s3/B1/ (B1, 229 s) — LOCALAI, space lost (R2 text)
  - renders/inkling_s1/B5/ (B5, 195 s) — logo horizontally squeezed (distorted) and VIDEO band overla
Qwen best:
  - renders/qwen_s2/B4/B4.mp4 (B4, 116 s)
  - renders/qwen_s1/B4/B4.mp4 (B4, 132 s)
  - renders/qwen_s4/B4/B4.mp4 (B4, 138 s)
Qwen worst (render dir, no mp4 where noted):
  - renders/qwen_s2/B1/ (B1, 1591 s) — R1: no HTML in 3 rounds (every round hit the 20k output cap,
  - renders/qwen_s3/B1/ (B1, 1583 s) — R1: no HTML in 3 rounds (every round hit the 20k output cap,
  - renders/qwen_s2/B5/ (B5, 1583 s) — R1: no HTML in 3 rounds (every round hit the 20k output cap,
All renders are kept under `renders/<model>_s<seed>/<brief>/` (mp4, every round's HTML, the model's reasoning, `log.json`); per-attempt rows with blind id, verdict, wall time, tokens, fix rounds, VRAM peak in `results.json`; raw per-attempt lines in `results.jsonl`.

## Files
`RESULTS.md`, `results.json`, `results.jsonl`, `summary.json`, `blind/` (anonymous sheets), `SEALED-mapping.json`, `blind_verdicts.json`, `duel.sh`, `runner.py`, `blind_pack.py`, `vram.csv` (resume run only); run and server logs are not included.

## Verifier pass (2026-11-23T00:40Z, recomputed from results.json, results.jsonl, log.json, vram.csv)
All headline counts, per-brief counts, fix rounds, wall and token means and medians, Fisher p (0.2733), the 5 no-HTML Qwen attempts (s2 B1, s2 B5, s3 B1, s4 B3, s4 B5: 3 rounds each at 20,000 tokens, finish=length) and the best/worst lists check out. Corrected above: VRAM units (the figures were MiB written as GB) and the unsupported "earlier sampled run" note removed; the model of each post-render failure added; token median rounding. Not provable from file times: that the verdicts were written before the mapping was opened (mapping file 19:59:51Z, verdicts 20:00:44Z); it rests on the grader's statement. Speed ratio: 4.06x by mean, 4.05x by median.
