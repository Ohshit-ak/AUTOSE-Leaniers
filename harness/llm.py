"""Unified LLM caller for DeepSeek, Groq and Gemma (Google AI Studio)."""
import os
import re

from config import API_KEY_VARS, BASE_URLS, MODELS, TEMPERATURE


def _api_key(provider: str) -> str:
    var = API_KEY_VARS[provider]
    key = os.getenv(var)
    if not key:
        raise RuntimeError(f"{var} is not set; add it to .env")
    return key


def call_llm(prompt: str, system: str = "", model: str = "deepseek") -> str:
    """Call a model by provider name. Returns the response text."""
    if model not in MODELS:
        raise ValueError(f"unknown model {model!r}; choose from {list(MODELS)}")

    if model in BASE_URLS:
        from openai import OpenAI

        client = OpenAI(api_key=_api_key(model), base_url=BASE_URLS[model])
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})
        resp = client.chat.completions.create(
            model=MODELS[model], messages=messages, temperature=TEMPERATURE
        )
        return resp.choices[0].message.content

    from google import genai

    client = genai.Client(api_key=_api_key(model))
    # Gemma has no system role, so the system prompt goes in front of the user prompt.
    contents = f"{system}\n\n{prompt}" if system else prompt
    resp = client.models.generate_content(
        model=MODELS[model],
        contents=contents,
        config={"temperature": TEMPERATURE},
    )
    return resp.text


_FENCE = re.compile(r"```(?:lean4?|Lean)?\s*\n(.*?)```", re.DOTALL)
_THINK = re.compile(r"<think>.*?</think>", re.DOTALL)


def extract_lean(text: str) -> str:
    """Pull Lean code out of a model reply (fenced blocks, reasoning tags stripped)."""
    text = _THINK.sub("", text)
    blocks = _FENCE.findall(text)
    return "\n\n".join(b.strip() for b in blocks) if blocks else text.strip()
