"""Unified LLM caller for DeepSeek, Groq, Gemma (Google AI Studio) and local Qwen."""
import os
import re
import time

from config import API_KEY_VARS, API_RETRIES, BASE_URLS, MODELS, TEMPERATURE


def _api_key(provider: str) -> str:
    var = API_KEY_VARS[provider]
    if var is None:
        return "not-needed"  # local server; the OpenAI client still wants a string
    key = os.getenv(var)
    if not key:
        raise RuntimeError(f"{var} is not set; add it to .env")
    return key


class EmptyReply(Exception):
    """The API call succeeded but the reply has no text."""


def _transient(e: Exception) -> bool:
    """Server overload, 5xx, rate limit or network blip: worth retrying."""
    code = getattr(e, "code", None) or getattr(e, "status_code", None)
    if code in (429, 500, 502, 503, 504):
        return True
    return type(e).__name__ in ("ConnectError", "ReadTimeout", "APIConnectionError",
                                "APITimeoutError", "RemoteProtocolError", "EmptyReply")


def call_llm(prompt: str, system: str = "", model: str = "deepseek",
             history=None, temperature: float = TEMPERATURE) -> str:
    """Call a model by provider name, retrying transient API errors. Returns the response text.

    `history` is a list of earlier {"role": "user"|"assistant", "content": ...} turns
    that go between the system prompt and `prompt`.
    """
    for attempt in range(API_RETRIES + 1):
        try:
            text = _call_llm_once(prompt, system, model, history or [], temperature)
            if not text:  # Gemma sometimes answers with no text at all
                raise EmptyReply(f"{model} returned no text")
            return text
        except Exception as e:
            if attempt == API_RETRIES or not _transient(e):
                raise
            wait = min(10 * 2 ** attempt, 120)
            print(f"  api error ({type(e).__name__}), retry {attempt + 1}/{API_RETRIES} in {wait}s")
            time.sleep(wait)


def _call_llm_once(prompt: str, system: str, model: str, history: list, temperature: float) -> str:
    if model not in MODELS:
        raise ValueError(f"unknown model {model!r}; choose from {list(MODELS)}")

    if model in BASE_URLS:
        from openai import OpenAI

        client = OpenAI(api_key=_api_key(model), base_url=BASE_URLS[model])
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages += history
        messages.append({"role": "user", "content": prompt})
        resp = client.chat.completions.create(
            model=MODELS[model], messages=messages, temperature=temperature
        )
        return resp.choices[0].message.content

    from google import genai

    client = genai.Client(api_key=_api_key(model))
    # Gemma has no system role, so the system prompt goes in front of the first user turn.
    turns = history + [{"role": "user", "content": prompt}]
    if system:
        turns[0] = {"role": "user", "content": f"{system}\n\n{turns[0]['content']}"}
    contents = [{"role": "model" if t["role"] == "assistant" else "user",
                 "parts": [{"text": t["content"]}]} for t in turns]
    resp = client.models.generate_content(
        model=MODELS[model],
        contents=contents,
        config={"temperature": temperature},
    )
    return resp.text


_FENCE = re.compile(r"```(?:lean4?|Lean)?\s*\n(.*?)```", re.DOTALL)
_THINK = re.compile(r"<think>.*?</think>", re.DOTALL)


def extract_lean(text: str) -> str:
    """Pull Lean code out of a model reply (fenced blocks, reasoning tags stripped)."""
    text = _THINK.sub("", text)
    blocks = _FENCE.findall(text)
    return "\n\n".join(b.strip() for b in blocks) if blocks else text.strip()
