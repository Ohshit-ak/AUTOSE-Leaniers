# MEMORY.md — Project State & Decisions

A running log of where ContractForge stands, why things are the way they are,
and what comes next. Update it whenever you finish a piece of work or make a
decision someone else would need to know.

## Status (2026-10-30)

| Part | State |
|------|-------|
| `framework/` (Lean library) | Done for v0. Builds with `lake build`; `Test.lean` smoke test passes. |
| `harness/config.py` | Done. Models, keys, retries, timeouts, API retry count (`CF_API_RETRIES`). |
| `harness/llm.py` | Done. DeepSeek / Groq / Gemma / local Qwen. Retries transient API errors (429, 5xx, network) with exponential backoff (10s → max 120s). |
| `harness/lean_runner.py` | Done. |
| `harness/req_parser.py` | Done (2026-10-28). SRS XML → requirements JSON, deterministic, no LLM. Tests in `harness/tests/`. |
| `harness/agents/spec_agent.py` (L0) | Done. Prompt hardened 2026-10-30 (see *Decisions*). Builds prompts from parser JSON (`spec_prompts`, `run_spec_from_json`). |
| `harness/agents/` (L1/L2) | Written, not yet run end to end. |
| `harness/main.py` | Single entry point. Stages `parse` → `spec` (L0) work; L1/L2 not wired yet. Auto-starts the Qwen server. |
| `harness/reverify.py` | Not started. |
| `benchmark/`, `evaluation/` | Empty directories. |
| `requirements.txt` | Not created yet. |

## L0 results so far (input: `Requirements/0000 - gamma j.xml`)

The parser yields 75 entries: 35 requirements, 20 data constraints, 20 use cases (219 statements dropped, each with its reason).

| Model | Entries | Lean-checked | Result | Where | Notes |
|-------|---------|--------------|--------|-------|-------|
| Qwen 2.5 7B (local) | 75 | **No** (`--skip-lean`) | 75 unchecked | `runs/specs.json`, `runs/lean/` (committed 2373f8e) | Older output layout; should live under `runs/0000 - gamma j/qwen/`. Not a pass rate. |
| Gemma (`gemma-4-31b-it`) | 4 (`1.4/I3`, `1.4/S2`, `1.4/S3`, `1.4/S4`) | Yes | 4/4 pass, mean 1.5 attempts, 2–5.5 min each | `runs/0000 - gamma j/gemma/` (uncommitted) | First run with the hardened prompt. Slow because of API retries. |

## Decisions

- **Lean version:** use the installed Lean 4.29.1 (`framework/lean-toolchain`). Do not reinstall via elan.
- **Python:** use the local miniconda Python; teammates can use a venv (see README).
- **No Mathlib.** Framework and prompts use Lean core only (`List.Pairwise`, `List.Perm`) to keep builds fast.
- **Keys live in `.env`** (gitignored) and are loaded by `config.py` via `python-dotenv`. `.env.example` holds key *names only*.
- **Model ids are overridable** with env vars (`CF_DEEPSEEK_MODEL`, `CF_GROQ_MODEL`, `CF_GEMMA_MODEL`, `CF_QWEN_MODEL`) so a renamed model doesn't need a code change.
- **Groq default is `llama-3.3-70b-versatile`**, not the guide's `deepseek-r1-distill-llama-70b`.
- **Gemma default is `gemma-4-31b-it`** (changed from `gemma-4-27b-it`, 2026-10-30).
- **Default `--model` in `main.py` is `qwen`** (or `$CF_MODEL`).
- **Agents never write `import` lines.** `lean_runner.check_lean` strips them and prepends `import ContractForge` / `open ContractForge`.
- **`sorry` counts as failure** in `check_lean`.
- **Locked context:** already-verified Lean (spec, contracts) is passed as `context` to `generate_verified` and prepended at check time, so later agents can't change it.
- **Gemma has no system role**, so `llm.py` puts the system prompt in front of the user prompt.
- **API errors are retried separately from Lean repairs.** `CF_API_RETRIES` (default 6) covers 429/5xx/network errors inside `call_llm`; `CF_MAX_RETRIES` (default 5) is the Lean generate → check → repair budget. Other exceptions are raised immediately.
- **L0 prompt hardening (2026-10-30).** The models kept making the same mistakes, so the spec prompt now:
  - says `Contract` already exists and must not be redefined;
  - requires `structure Input` / `structure Output` defined before `Spec`;
  - requires a satisfiability `example` of the form `Spec.pre i ∧ Spec.post i o` (never `Spec x y`);
  - forbids Bool `true`/`false` used as a `Prop`;
  - lists Lean 3 syntax to avoid (`begin…end`, `λ x,`, `cases … with`, `split`, comma-separated tactics, `#eval`);
  - includes a full template that compiles.
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
- Run `lake build` in `framework/` once before the harness, or `import ContractForge` won't resolve (`main.py` builds it on first run).
- **A real Gemini key was committed to `.env.example` in `dd2bdfe` and pushed to GitHub.** The working copy is now blanked, but the key is still in history: **revoke it in Google AI Studio** and put a new one in `.env`.
- **Stray gitlink `AUTOSE-Leaniers`** at the repo root (mode 160000, no `.gitmodules`), added in 2573d72. It's an accidental self-reference; remove it with `git rm --cached AUTOSE-Leaniers`.
- `Requirements/parsed/0000 - gamma j.json` committed in 2573d72 was parsed from an older XML; re-parsing the current XML only changes `source.sha256`.
- `runs/qwen_server.log` is written by `main.py` and isn't gitignored yet.

## Next steps

1. Revoke the leaked Gemini key; remove the stray `AUTOSE-Leaniers` gitlink.
2. Re-run Qwen L0 **with Lean checking** on a GPU node (`python main.py --model qwen`), and move/delete the old unchecked `runs/specs.json` + `runs/lean/`.
3. Run Gemma (and DeepSeek/Groq if keys are available) on all 75 entries with `--resume` to get comparable L0 pass rates.
4. Wire L1 (architect) and L2 (coding) stages into `main.py`.
5. Add `requirements.txt` (`google-genai`, `openai`, `python-dotenv`).
6. First benchmark system: `benchmark/bank_ledger/`.
7. `evaluation/metrics.py` with the `RunResult` dataclass from the kickoff guide.
