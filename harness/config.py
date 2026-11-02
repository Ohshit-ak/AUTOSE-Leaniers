"""Model selection and API keys. Keys come from .env at the repo root."""
import os
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")

FRAMEWORK_PATH = ROOT / "framework"

MAX_RETRIES = int(os.getenv("CF_MAX_RETRIES", "5"))
LEAN_TIMEOUT = int(os.getenv("CF_LEAN_TIMEOUT", "60"))
API_RETRIES = int(os.getenv("CF_API_RETRIES", "6"))  # 5xx / 429 / network errors, with backoff
TEMPERATURE = float(os.getenv("CF_TEMPERATURE", "0.2"))
# Used when the repair loop restarts from scratch after the same error twice.
RESTART_TEMPERATURE = float(os.getenv("CF_RESTART_TEMPERATURE", "0.7"))
# Reply length. Specs are under ~1000 tokens; a reply that hits MAX_TOKENS is retried once
# with MAX_TOKENS_RETRY, and if it is still cut off the attempt counts as `truncated`
# (it is not sent to Lean). Without a limit a runaway reply runs until the context is full.
MAX_TOKENS = int(os.getenv("CF_MAX_TOKENS", "2048"))
MAX_TOKENS_RETRY = int(os.getenv("CF_MAX_TOKENS_RETRY", "4096"))
# Sampling seed sent with every request where the provider supports it (local Qwen).
# `main.py --repeat N` uses SEED, SEED+1, …, one per repetition, so repetitions differ
# but each one can be reproduced. The llama.cpp server's own `--seed 42` is only its default.
SEED = int(os.getenv("CF_SEED", "42"))
SEEDED_PROVIDERS = {"qwen"}
# Harness version, recorded in every specs.json and used in the default run name.
HARNESS_VERSION = os.getenv("CF_HARNESS_VERSION", "v10.1")
# L0 negative check: after a spec compiles, the model names an output the requirement
# forbids, and Lean must prove that `post` rejects it (agents/negative.py).
NEGATIVE_CHECK = os.getenv("CF_NEGATIVE_CHECK", "1") == "1"
NEG_EXAMPLE_ATTEMPTS = int(os.getenv("CF_NEG_ATTEMPTS", "2"))  # tries to get a usable bad example

# Provider name -> model id. Override any of these via env vars if a
# provider renames or retires a model.
MODELS = {
    "deepseek": os.getenv("CF_DEEPSEEK_MODEL", "deepseek-chat"),
    "groq": os.getenv("CF_GROQ_MODEL", "llama-3.3-70b-versatile"),
    "gemma": os.getenv("CF_GEMMA_MODEL", "gemma-4-31b-it"),
    # Local Qwen 2.5 7B served by llama.cpp (scripts/start_qwen_server.sh).
    "qwen": os.getenv("CF_QWEN_MODEL", "qwen2.5-7b-instruct"),
}

# Port 8082 is this project's own; 8080/8081 belong to other projects on ada.
BASE_URLS = {
    "deepseek": "https://api.deepseek.com",
    "groq": "https://api.groq.com/openai/v1",
    "qwen": os.getenv("CF_QWEN_BASE_URL", "http://127.0.0.1:8082/v1"),
}

# None = no key needed (local server).
API_KEY_VARS = {
    "deepseek": "DEEPSEEK_API_KEY",
    "groq": "GROQ_API_KEY",
    "gemma": "GEMINI_API_KEY",
    "qwen": None,
}
