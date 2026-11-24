# inkling-vs-qwen-motion-graphics-test

Two local models, the same five motion-graphics briefs, four tries each per setup, one RTX 4090. Each model has to write one
HTML + GSAP composition per brief; HyperFrames checks it, renders it to an mp4 on the CPU, and up to two automatic fix rounds feed
back only the tool's error text. This repo holds the briefs, the harness, every attempt (mp4, each round's HTML, the model's reply)
and the raw numbers, so you can check or re-run it.

- **Inkling 2 Mini**, IQ4_NL (`ggml-org/Inkling-2-Mini-GGUF`), reasoning on at its default (high).
- **Qwen3.8-27B**, Q4_K_M (`ggml-org/Qwen3.8-27B-GGUF`), thinking on (default).
- **Arm C**, added after the first result was known: the same Qwen file with thinking off. Only Qwen got this arm. It is exploratory.

5 briefs x seeds 1-4 = 20 attempts per arm. Briefs and pass rules (R1 renders, R2 matches the brief, R3 no broken layout) are in
`briefs/briefs.md`; they were fixed before the first run.

## Result (from `results/RESULTS.md` and `results/RESULTS-armc.md`)

| | Inkling 2 Mini IQ4_NL | Qwen3.8-27B Q4_K_M, thinking on | Qwen3.8-27B Q4_K_M, thinking off (added after the first result; exploratory) |
|---|---|---|---|
| Pass (R1-R3) | 17 / 20 (85 %) | 13 / 20 (65 %) | 13 / 20 (65 %) |
| Rendered an mp4 (R1) | 20 / 20 | 15 / 20 (5 attempts never produced HTML: every round hit the 20k output cap) | 19 / 20 (1 no mp4: 3 rounds of check errors) |
| Pass among rendered | 17 / 20 | 13 / 15 | 13 / 19 |
| Per brief B1 / B2 / B3 / B4 / B5 | 3, 4, 4, 4, 2 | 0, 4, 3, 4, 2 | 0, 4, 2, 4, 3 |
| Fix rounds used (total) | 2 | 18 | 8 |
| Wall per attempt, mean / median | 210 s / 193 s | 850 s / 780 s | 62 s / 59 s |
| Output tokens per attempt, mean / median | 12176 / 11146 | 32045 / 29321 | 2016 / 1912 |
| Total wall (20 attempts) | 1.16 h | 4.72 h | 0.34 h |
| Peak VRAM (whole card, ctx 32k, q8_0 KV) | 21,824 MiB, sampled in the resume run only | 20,640 MiB, one sampled peak, resume run only | 20,626 MiB, sampled over the whole run |

Inkling vs Qwen with thinking on, passes: Fisher exact p = 0.27 (two-sided). In this setup an Inkling attempt took about 4x less
wall time than a Qwen thinking-on attempt (210 s vs 850 s mean); the title card (B1) passed 0 of 8 times across both Qwen arms.
Attempts, verdicts and notes per attempt: `results/results.json`, `results/results_armc.json`, `results/blind_verdicts*.json`.

## Limits

- Twenty tries per arm are too few to call a winner on passes (17/20 vs 13/20 vs 13/20 is inside the noise).
- The 20,000-token reply limit per call was ours. The maker of Qwen recommends far more room for reasoning (131,072 tokens for the
  final response and 262,144 for reasoning, see `sources/model-cards-2026-11-23.md`). Five thinking-on attempts hit our limit.
- The same sampler was used for both models (temperature 0.6, top_p 0.95), not each maker's recommendation.
- Arm C was added later and only for Qwen.
- The grader is an AI working from nine frames per clip (not from watching it), with the model name hidden. Twelve of twelve sheets
  re-graded as decoys in arm C got the same verdict as in the first run.
- One kind of task: short motion-graphics cards in HyperFrames. Nothing here says how either model does anything else.
- No CUDA build (llama.cpp Vulkan on an NVIDIA card), no 16 GB card, no context above 32k.

## Exact setup

- Runtime: upstream llama.cpp **b12631, Vulkan build**. Server flags: `-c 32768 -ngl 99 -fa on --cache-type-k q8_0
  --cache-type-v q8_0 --parallel 1 --threads 4 --jinja --no-webui`, one model on the card at a time.
- Files: `Inkling-2-Mini-IQ4_NL.gguf` (17.63 GB, sha256 cbdf3fa9...2a81af4);
  `Qwen3.8-27B-Q4_K_M.gguf` taken from the current `main` of the repo, saved as `Qwen3.8-27B-Q4_K_M.main-d15d4b6d.gguf`
  (sha256 `d15d4b6de55f662ac40e867702d31afe738d032fa06b829b2b1a21a49d4a48ee`). Weights are not in this repo.
- Request: `temperature 0.6, top_p 0.95, max_tokens 20000`, seed 1-4, up to 3 calls per attempt (draft + 2 fix rounds).
  Arm C adds `chat_template_kwargs {"enable_thinking": false}` (`NOTHINK=1` in `harness/runner.py`).
- **HyperFrames 0.8.176** (pinned, not redistributed) with GSAP 3.14.2 (not redistributed), CPU render, 1920x1080, 24 fps.
- Harness notes: the Qwen file was still downloading when the run started, so block order was not strictly interleaved and one
  block was killed by a memory limit and resumed; details in `results/RESULTS.md`.

## Re-run

1. `cd harness && npm install hyperframes@0.8.176 gsap@3.14.2`, then copy `node_modules/gsap/dist/gsap.min.js` to
   `tpl/vendor/gsap.min.js` (the fonts and `tpl/lib/gw.css` are already in `tpl/`).
2. Brief 5 needs two image assets of your own: `tpl/assets/logo-negative.png` and `tpl/assets/icon.svg`. We left ours out.
3. Put the llama.cpp b12631 Vulkan build and the two GGUF files somewhere and point to them:
   `LLAMA_BIN=... INKLING_GGUF=... QWEN_GGUF=... ./duel.sh 0` (arms A and B), then `./armc.sh` (arm C).
   Outputs go to `harness/renders/<model>_s<seed>/<brief>/`.
4. Blind sheets: `python3 blind_pack.py` and `python3 blind_pack_armc.py` (needs ffmpeg and ffprobe).
   The scripts expect a Linux box with `nvidia-smi`; `harness/hf` needs Node.
   Public copy: the scripts are the ones that ran, with two edits: the comment naming our internal job scheduler is reworded and
   the local server address is written as `localhost` (the run used the loopback IP).

## Folder map

- `briefs/` the five briefs and the pass rules.
- `harness/` runner, the two run scripts, the two blind-pack scripts, `scaffold/` (system prompt + example), `tpl/` (project template
  with the three OFL fonts and their licence texts, without the two brand images and without GSAP), `hf` (HyperFrames wrapper), `package.json`.
- `results/` result tables, per-attempt JSON and JSONL, summary, blind verdicts, the two mappings (anonymous id to model; opened only
  after grading), VRAM samples.
- `renders/<arm>_s<seed>/<brief>/` per attempt: final mp4 when it exists, `index_round*.html`, `llm_round*.txt` (the model's reply,
  reasoning included where it was on), `log.json`. Arms: `inkling`, `qwen` (thinking on), `qwennothink` (arm C).
- `sheets/` the nine-frame contact sheets the grader saw (`first-run/`, `arm-c/`), with the brief id and clip length per sheet.
- `sources/` the model-card passages read for the setup.

## Licence

Our scripts, briefs and text: MIT (`LICENSE`). The HTML and videos in `renders/` were written and rendered by the two models under
test; see `NOTICE.md`. Model licences: Inkling 2 Mini is Apache-2.0 (model page `thinkingmachines/Inkling-2-Mini`, provider Thinking
Machines Lab, Inc.); Qwen3.8-27B is Apache-2.0 (model card `Qwen/Qwen3.8-27B`); both pages read 2026-11-23. Not affiliated with
either maker.
