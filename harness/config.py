"""Model selection and API keys. Keys come from .env at the repo root."""
import os
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")

FRAMEWORK_PATH = ROOT / "framework"

MAX_RETRIES = int(os.getenv("CF_MAX_RETRIES", "5"))
LEAN_TIMEOUT = int(os.getenv("CF_LEAN_TIMEOUT", "60"))
TEMPERATURE = 0.2

# Provider name -> model id. Override any of these via env vars if a
# provider renames or retires a model.
MODELS = {
    "deepseek": os.getenv("CF_DEEPSEEK_MODEL", "deepseek-chat"),
    "groq": os.getenv("CF_GROQ_MODEL", "llama-3.3-70b-versatile"),
    "gemma": os.getenv("CF_GEMMA_MODEL", "gemma-4-27b-it"),
}

BASE_URLS = {
    "deepseek": "https://api.deepseek.com",
    "groq": "https://api.groq.com/openai/v1",
}

API_KEY_VARS = {
    "deepseek": "DEEPSEEK_API_KEY",
    "groq": "GROQ_API_KEY",
    "gemma": "GEMINI_API_KEY",
}
