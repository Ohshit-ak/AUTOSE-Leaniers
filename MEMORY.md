# MEMORY.md — Project State & Decisions

A running log of where ContractForge stands, why things are the way they are,
and what comes next. Update it whenever you finish a piece of work or make a
decision someone else would need to know.

## Status (2026-10-26)

| Part | State |
|------|-------|
| `framework/` (Lean library) | Done for v0. Builds with `lake build`; `Test.lean` smoke test passes. |
| `harness/config.py` | Done. Models, keys, retries, timeouts. |
| `harness/llm.py` | Written. Gemma model name not yet checked against the live API. |
| `harness/lean_runner.py` | Done. |
| `harness/req_parser.py` | Done (2026-10-28). SRS XML → requirements JSON, deterministic, no LLM. Tests in `harness/tests/`. |
| `harness/agents/` (L0/L1/L2) | Written, not yet run end to end. L0 can now read the parser JSON (`run_spec_from_json`). |
| `harness/main.py` | Single entry point. Stages `parse` → `spec` (L0) work; L1/L2 not wired yet. Auto-starts the Qwen server. |
| `harness/reverify.py` | Not started. |
| `benchmark/` | Not started. |
| `evaluation/` | Not started. |
| `requirements.txt` | Not created yet. |

## Decisions

- **Lean version:** use the installed Lean 4.29.1 (`framework/lean-toolchain`). Do not reinstall via elan.
- **Python:** use the local miniconda Python; teammates can use a venv (see README).
- **No Mathlib.** Framework and prompts use Lean core only (`List.Pairwise`, `List.Perm`) to keep builds fast.
- **Keys live in `.env`** (gitignored) and are loaded by `config.py` via `python-dotenv`. `.env.example` holds key *names only*.
- **Model ids are overridable** with env vars (`CF_DEEPSEEK_MODEL`, `CF_GROQ_MODEL`, `CF_GEMMA_MODEL`) so a renamed model doesn't need a code change.
- **Groq default is `llama-3.3-70b-versatile`**, not the guide's `deepseek-r1-distill-llama-70b`.
- **Agents never write `import` lines.** `lean_runner.check_lean` strips them and prepends `import ContractForge` / `open ContractForge`.
- **`sorry` counts as failure** in `check_lean`.
- **Locked context:** already-verified Lean (spec, contracts) is passed as `context` to `generate_verified` and prepended at check time, so later agents can't change it.
- **Gemma has no system role**, so `llm.py` puts the system prompt in front of the user prompt.

- **Requirements parser is rule-based and must stay AI-free.** Same XML bytes → same JSON bytes (tested across hash seeds). Every dropped statement is kept in `dropped` with the rule that removed it; tune the word lists at the top of `req_parser.py`, not ad hoc.
- **Performance requirements are kept**, tagged `verification: "lean+python_runtime"`. Bounds are integers (µs, per-second, counts) so a Python-measured value can be checked against the Lean spec with `decide`.
- Module is `req_parser.py`, not `parser.py`: Python 3.9 ships a stdlib `parser` module.
- **Local Qwen (`model="qwen"`)** = Qwen 2.5 7B GGUF via llama.cpp `llama-server` on **port 8082** (`scripts/start_qwen_server.sh`). Kept isolated from other projects on ada: own port (8080 vrspecml, 8081 housing-trends), own `CF_`-prefixed env vars, own `venv/` inside this repo; the shared model file and binary are only read.

## Proof obligations (naming used everywhere)

- **PO1** `Contract.Compatible c₁ c₂` — c₁'s guarantee meets c₂'s assumption.
- **PO2** `Contract.Refines c s` — composed contract refines the spec.
- **PO3** `Contract.Satisfies c f` — implementation meets its contract.
- `Contract.system_sound` combines PO1 + PO2 + PO3 into end-to-end correctness.

## Gotchas

- Run harness code from inside `harness/` (modules import each other as `from config import ...`).
- Run `lake build` in `framework/` once before the harness, or `import ContractForge` won't resolve.
- **`.env.example` currently contains a real Gemini key.** Move it to `.env` and blank it out before the first commit.

## Next steps

1. Verify the Gemma model id against the API (load the key from `.env`).
2. Write `harness/main.py` (L0 → L1 → parallel L2 using `extract_contracts`).
3. Add `requirements.txt` (`google-genai`, `openai`, `python-dotenv`).
4. First benchmark system: `benchmark/bank_ledger/`.
5. `evaluation/metrics.py` with the `RunResult` dataclass from the kickoff guide.
