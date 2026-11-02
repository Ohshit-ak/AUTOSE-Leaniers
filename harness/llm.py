"""Unified LLM caller for DeepSeek, Groq, Gemma (Google AI Studio) and local Qwen."""
import os
import re
import time

from config import (API_KEY_VARS, API_RETRIES, BASE_URLS, MAX_TOKENS, MAX_TOKENS_RETRY, MODELS, SEED,
                    SEEDED_PROVIDERS, TEMPERATURE)

_seed = SEED


def set_seed(seed: int) -> None:
    """Seed for every following request (providers in SEEDED_PROVIDERS only)."""
    global _seed
    _seed = seed


def current_seed(model: str):
    """The seed requests to `model` use, or None if the provider takes no seed."""
    return _seed if model in SEEDED_PROVIDERS else None


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


class Truncated(Exception):
    """The reply was cut off (token limit, or a code fence that never closes), even after
    one retry with MAX_TOKENS_RETRY. `text` is the cut-off reply."""

    def __init__(self, text: str, max_tokens: int):
        super().__init__(f"reply cut off at {max_tokens} tokens")
        self.text, self.max_tokens = text, max_tokens


def is_truncated(text: str, finish_reason) -> bool:
    """Cut off by the token limit. When the provider reports no finish reason, a ``` fence
    that is opened and never closed counts as cut off too. (A reply that ended normally
    but forgot its closing fence is complete; `extract_lean` handles it.)"""
    reason = str(finish_reason).lower() if finish_reason is not None else None
    if reason is not None and ("length" in reason or "max_tokens" in reason):
        return True
    return reason is None and (text or "").count("```") % 2 == 1


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
    text, finish = _call_with_retries(prompt, system, model, history, temperature, MAX_TOKENS)
    if not is_truncated(text, finish):
        return text
    print(f"  reply cut off at {MAX_TOKENS} tokens; retrying once with {MAX_TOKENS_RETRY}")
    text, finish = _call_with_retries(prompt, system, model, history, temperature, MAX_TOKENS_RETRY)
    if is_truncated(text, finish):
        raise Truncated(text, MAX_TOKENS_RETRY)
    return text


def _call_with_retries(prompt, system, model, history, temperature, max_tokens):
    for attempt in range(API_RETRIES + 1):
        try:
            text, finish = _call_llm_once(prompt, system, model, history or [], temperature, max_tokens)
            if not text:  # Gemma sometimes answers with no text at all
                raise EmptyReply(f"{model} returned no text")
            return text, finish
        except Exception as e:
            if attempt == API_RETRIES or not _transient(e):
                raise
            wait = min(10 * 2 ** attempt, 120)
            print(f"  api error ({type(e).__name__}), retry {attempt + 1}/{API_RETRIES} in {wait}s")
            time.sleep(wait)


def _call_llm_once(prompt: str, system: str, model: str, history: list, temperature: float,
                   max_tokens: int):
    """(reply text, finish reason)."""
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
        extra = {"seed": _seed} if model in SEEDED_PROVIDERS else {}
        resp = client.chat.completions.create(
            model=MODELS[model], messages=messages, temperature=temperature,
            max_tokens=max_tokens, **extra
        )
        return resp.choices[0].message.content, resp.choices[0].finish_reason

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
        config={"temperature": temperature, "max_output_tokens": max_tokens},
    )
    finish = resp.candidates[0].finish_reason if getattr(resp, "candidates", None) else None
    return resp.text, finish


_FENCE = re.compile(r"```[ \t]*(?:lean4?|Lean)?[ \t]*\n(.*?)```", re.DOTALL)
_OPEN_FENCE = re.compile(r"```[ \t]*(?:lean4?|Lean)?[ \t]*\n")
_THINK = re.compile(r"<think>.*?</think>", re.DOTALL)
# Lines a Lean file can start with; anything before the first one is prose.
_LEAN_START = re.compile(r"^(?:(?:structure|def|example|theorem|abbrev|inductive|instance|namespace|"
                         r"open|set_option|variable|section)\b|--|/-|@\[)", re.MULTILINE)


def extract_lean(text: str) -> str:
    """Pull Lean code out of a model reply (fenced blocks, reasoning tags stripped).

    A reply with several blocks is usually a draft followed by a corrected version;
    joining them declares `Input`/`Output`/`Spec` twice. Keep the last block that
    defines `Spec`, else the last block. Without closed fences, take what follows an
    opening fence (or the reply from its first Lean line), drop prose before the code,
    and remove lines that are only backticks.
    """
    text = _THINK.sub("", text or "")
    blocks = [b.strip() for b in _FENCE.findall(text)]
    if blocks:
        with_spec = [b for b in blocks if re.search(r"^def\s+Spec\b", b, re.MULTILINE)]
        code = (with_spec or blocks)[-1]
    else:
        opens = list(_OPEN_FENCE.finditer(text))
        code = text[opens[-1].end():] if opens else text
        m = _LEAN_START.search(code)
        if m:
            code = code[m.start():]
    code = "\n".join(ln for ln in code.splitlines() if not re.fullmatch(r"\s*`{3,}\w*\s*", ln))
    return code.strip()
