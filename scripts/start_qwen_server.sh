#!/usr/bin/env bash
# Serve the local Qwen 2.5 7B Instruct (GGUF, Q4_K_M) for ContractForge with llama.cpp's llama-server:
# an OpenAI-compatible API at http://$CF_QWEN_HOST:$CF_QWEN_PORT/v1, used by `model="qwen"` in harness/llm.py.
#
# Run it on a GPU node (the llama-server build needs CUDA), e.g.:
#   srun -p u22 --gres=gpu:1 --pty bash      then    bash scripts/start_qwen_server.sh
# Run the harness on the same node (it connects to 127.0.0.1). Foreground process: stop it with Ctrl-C.
#
# The model file and the llama-server binary are shared with other projects and only read, never modified.
# Port 8082 is this project's own (8080: vrspecml, 8081: housing-trends), so they can all run side by side.
# Settings (CF_ prefix so they never collide with other projects' variables):
#   CF_LLAMA_SERVER  llama-server binary          CF_QWEN_GGUF  first shard of the model
#   CF_QWEN_HOST     bind address (127.0.0.1)     CF_QWEN_PORT  port (8082)
#   CF_QWEN_CTX      context size (16384; repair conversations need more than 8192)          CF_QWEN_NGL   layers offloaded to the GPU (99 = all)
#   CF_QWEN_JINJA    1 = start with --jinja (the model's own chat template), needed for tool calls
#                    (L1 agent mode). Off by default so L0 runs keep the server setup they were frozen with.
set -euo pipefail

GGUF="${CF_QWEN_GGUF:-$HOME/llm-models/qwen2.5-7b-instruct/qwen2.5-7b-instruct-q4_k_m-00001-of-00002.gguf}"
HOST="${CF_QWEN_HOST:-127.0.0.1}"
PORT="${CF_QWEN_PORT:-8082}"
CTX="${CF_QWEN_CTX:-16384}"
NGL="${CF_QWEN_NGL:-99}"
SERVER="${CF_LLAMA_SERVER:-$HOME/build/llama.cpp/build-cuda/bin/llama-server}"

[[ -x "$SERVER" ]] || { echo "llama-server not found: $SERVER (set CF_LLAMA_SERVER)" >&2; exit 1; }
[[ -f "$GGUF" ]] || { echo "model not found: $GGUF (set CF_QWEN_GGUF)" >&2; exit 1; }

echo "serving $GGUF at http://$HOST:$PORT/v1"
JINJA=()
[[ "${CF_QWEN_JINJA:-0}" == "1" ]] && JINJA=(--jinja)
exec "$SERVER" -m "$GGUF" --alias qwen2.5-7b-instruct --host "$HOST" --port "$PORT" \
     -c "$CTX" -ngl "$NGL" --seed 42 "${JINJA[@]}"
