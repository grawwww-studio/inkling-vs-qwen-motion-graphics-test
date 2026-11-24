# Model cards read for EP12 (2026-11-23, all three pages HTTP 200; quotes are from the pages)

## https://huggingface.co/Qwen/Qwen3.8-27B
- Thinking sampler: "Thinking Mode: `temperature=1.0`, `top_p=0.95`, `top_k=20`, `min_p=0.0`, `presence_penalty=0.0`, `repetition_penalty=1.0`"
- Non-thinking sampler: "Instruct (or non-thinking) mode: `temperature=0.7`, `top_p=0.80`, `top_k=20`, `min_p=0.0`, `presence_penalty=1.5`, `repetition_penalty=1.0`"
- Output length: "Reasoning Content: Set the maximum output length to 262,144 tokens." / "Final Response: Set the maximum output length to 131,072 tokens."
- Context: "Context Length: 262,144 natively and extensible up to 1,000,000 tokens."
- Reasoning control: "Qwen3.8 comes with official support for `reasoning_effort`"; levels "`xhigh` (default)", "`medium`", "`low`";
  `enable_thinking` "on by default"; non-thinking via `"chat_template_kwargs": {"enable_thinking": False}`;
  "Qwen3.8 models operate in thinking mode by default".
- Licence: "License: apache-2.0".

## https://huggingface.co/ggml-org/Qwen3.8-27B-GGUF (Files tab)
Main-model files: Qwen3.8-27B-BF16.gguf 53.8 GB; Qwen3.8-27B-Q8_0.gguf 28.6 GB; Qwen3.8-27B-Q4_K_M.gguf 19.4 GB.
Other files are auxiliary (dflash-*, mmproj-*, mtp-*). No IQ4_NL file. So Q4_K_M is the only 4-bit main-model file in this repo.

## https://huggingface.co/ggml-org/Inkling-2-Mini-GGUF (Files tab)
Main-model files: Inkling-2-Mini-BF16.gguf 52.2 GB; Inkling-2-Mini-Q8_0.gguf 27.8 GB; Inkling-2-Mini-IQ4_NL.gguf 17.6 GB
("IQ4_NL | 17.6 GB | imatrix-calibrated. 4-bit experts in layers 0-19, everything else at Q8_0"). No Q4_K_M file.
- Reasoning control: "Reasoning depth is set with `reasoning_effort`: `none`, `minimal`, `low`, `medium`, `high` (the default), `xhigh` or `max`, or a number from 0.0 to 0.99."
- Sampler recommendation: not stated on the page. Minimum llama.cpp build: not stated on the page. Licence: no licence line on this page
  (source model linked as https://huggingface.co/thinkingmachines/Inkling-2-Mini, not read).
- Architecture as stated: "Inkling 2 Mini is a looped mixture-of-experts model (128 experts, 8 active per token) with image input. It has
  24 layers: layers 6-17 form a loop core that runs 3 times per token..."; metadata "Model size 26B params", "Architecture inkling2_loop".

Not verified anywhere: which reasoning effort the Qwen GGUF chat template applied under llama.cpp b12631 in our runs.
