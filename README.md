# AUTOSE-Leaniers — ContractForge

ContractForge is a multi-agent pipeline that turns an English requirement into
**formally verified Lean 4 code**. Each layer is checked by Lean before the
next one starts:

```
English requirement
   │  L0 spec agent        → Lean spec  (Spec : Contract Input Output)
   ▼
Lean spec
   │  L1 architect agent   → component contracts + proofs of PO1, PO2
   ▼
Contracts (locked)
   │  L2 coding agents     → implementations + proofs of PO3 (one per component)
   ▼
Verified system  (Contract.system_sound ⇒ end-to-end correctness)
```

> Current status, design decisions and next steps are in **[MEMORY.md](MEMORY.md)**. Read it first.

---

## Repository layout

```
AUTOSE-Leaniers/
├── README.md               # this file: what it is, how to navigate, how to use
├── MEMORY.md               # project state, decisions, gotchas, next steps
├── .env.example            # API key names (copy to .env)
├── .env                    # your API keys (gitignored)
│
├── framework/              # Lean 4 library (built with lake)
│   ├── lakefile.lean
│   ├── lean-toolchain      # Lean 4.29.1
│   ├── ContractForge.lean  # re-exports the modules below
│   ├── ContractForge/
│   │   ├── Contract.lean   # Contract type, PO1/PO2/PO3 definitions, seq composition
│   │   ├── Soundness.lean  # seq_sound, refines_sound, system_sound
│   │   └── Tactics.lean    # discharge_po tactic
│   └── Test.lean           # smoke test
│
└── harness/                # Python orchestration
    ├── config.py           # models, API keys, retry/timeout settings
    ├── llm.py              # call_llm(): DeepSeek / Groq / Gemma; extract_lean()
    ├── lean_runner.py      # check_lean(): type-checks code against the framework
    └── agents/
        ├── base.py             # generate → check → repair loop
        ├── spec_agent.py       # L0: requirement → spec
        ├── architect_agent.py  # L1: spec → contracts + PO1/PO2
        └── coding_agent.py     # L2: contract → impl + PO3
```

Planned, not yet created: `harness/main.py`, `harness/reverify.py`,
`benchmark/`, `evaluation/`, `requirements.txt` (see [MEMORY.md](MEMORY.md)).

### Where to look for…

| I want to… | Go to |
|------------|-------|
| Understand the core types and proof obligations | [framework/ContractForge/Contract.lean](framework/ContractForge/Contract.lean) |
| See why the pipeline is sound | [framework/ContractForge/Soundness.lean](framework/ContractForge/Soundness.lean) |
| Change the automatic proof tactic | [framework/ContractForge/Tactics.lean](framework/ContractForge/Tactics.lean) |
| Switch models or change retries/timeouts | [harness/config.py](harness/config.py) |
| Add a new LLM provider | [harness/llm.py](harness/llm.py) |
| Change how Lean is invoked or errors are reported | [harness/lean_runner.py](harness/lean_runner.py) |
| Edit an agent's system prompt | [harness/agents/](harness/agents/) |
| Change the retry/repair loop | [harness/agents/base.py](harness/agents/base.py) |

### Proof obligations

| PO | Lean definition | Meaning | Proved by |
|----|-----------------|---------|-----------|
| PO1 | `Contract.Compatible c₁ c₂` | c₁'s guarantee establishes c₂'s assumption | L1 |
| PO2 | `Contract.Refines c s` | the composed contract refines the spec | L1 |
| PO3 | `Contract.Satisfies c f` | implementation `f` meets contract `c` | L2 |

---

## Setup

### 1. Lean

Requires Lean 4.29.1 (see `framework/lean-toolchain`). Build the framework once:

```bash
cd framework
lake build
lake env lean Test.lean   # smoke test: no output means it passed
```

### 2. Python

Python 3.10+. Use a venv (or your existing conda env):

```bash
python -m venv venv
source venv/bin/activate
pip install google-genai openai python-dotenv
```

### 3. API keys

```bash
cp .env.example .env
```

Fill in the keys in `.env` (never in `.env.example`):

| Variable | Provider | Get it at |
|----------|----------|-----------|
| `DEEPSEEK_API_KEY` | DeepSeek (default model) | [platform.deepseek.com](https://platform.deepseek.com) |
| `GEMINI_API_KEY` | Google AI Studio (Gemma) | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) |
| `GROQ_API_KEY` | Groq (Llama 3.3 70B) | [console.groq.com](https://console.groq.com) |

You only need the key for the provider you use.

Optional overrides (also in `.env`):

| Variable | Default |
|----------|---------|
| `CF_DEEPSEEK_MODEL` | `deepseek-chat` |
| `CF_GROQ_MODEL` | `llama-3.3-70b-versatile` |
| `CF_GEMMA_MODEL` | `gemma-4-27b-it` |
| `CF_MAX_RETRIES` | `5` |
| `CF_LEAN_TIMEOUT` | `60` (seconds) |

---

## Usage

Run everything from inside `harness/`. The modules import each other by plain name.

```bash
cd harness
```

### Check that a model responds

```bash
python -c "from llm import call_llm; print(call_llm('Write hello world in Lean 4', model='deepseek'))"
```

`model` is one of `deepseek`, `groq`, `gemma` or `qwen`.

`qwen` is the local Qwen 2.5 7B on ada, served by llama.cpp on port 8082 (no API key).
Start it on a GPU node and run the harness on that same node:

```bash
srun -p u22 --gres=gpu:1 --pty bash
bash scripts/start_qwen_server.sh &        # wait for "server is listening"
source venv/bin/activate && cd harness
python -c "from llm import call_llm; print(call_llm('Write hello world in Lean 4', model='qwen'))"
```

### Type-check Lean code against the framework

```bash
python -c "from lean_runner import check_lean; print(check_lean('example : 1 + 1 = 2 := by decide'))"
```

It returns `{'success': True, ...}`, or `{'success': False, 'error': ...}` with
Lean's error message. A `sorry` counts as a failure.

### Run the agents step by step

`harness/main.py` doesn't exist yet. Until it does, chain the agents by hand:

```python
from agents.spec_agent import run_spec
from agents.architect_agent import run_architect, extract_contracts
from agents.coding_agent import run_coder

model = "deepseek"

spec = run_spec("A function that returns a sorted permutation of a list of naturals", model)
assert spec["success"], spec.get("error")

arch = run_architect(spec["code"], model)
assert arch["success"], arch.get("error")

locked = spec["code"] + "\n\n" + arch["code"]
for name in extract_contracts(arch["code"]):
    result = run_coder(name, locked, model)
    print(name, "OK" if result["success"] else "FAILED", f"({result['attempts']} attempts)")
```

Every agent returns `{"success", "code", "attempts"}`, plus `"error"` on failure.
On a failed check, the agent sends Lean's error back to the model and retries,
up to `CF_MAX_RETRIES` times.

### Writing Lean against the framework

```lean
-- import ContractForge / open ContractForge are added for you by check_lean
def incC : Contract Nat Nat := { pre := fun _ => True, post := fun x y => y > x }

theorem inc_ok : incC.Satisfies (· + 1) := by
  unfold incC; discharge_po
```

`discharge_po` unfolds the PO definitions and tries `simp_all`, `omega`,
`grind` and `decide`. If none of them closes the goal, write the proof by hand.

---

## Contributing

### Workflow

1. **Read [MEMORY.md](MEMORY.md)** to see what's done, what's in progress and what's next. Pick an item from *Next steps* and tell the team you're taking it.
2. **Pull and branch off `main`:**
   ```bash
   git checkout main && git pull
   git checkout -b <your-name>/<short-topic>    # e.g. akshith/main-loop
   ```
3. **Make your change.** Keep each branch to one topic.
4. **Check it before you push** (see the checklist below).
5. **Update [MEMORY.md](MEMORY.md):** status table, any new decisions or gotchas, and *Next steps*.
6. **Commit and push**, then open a pull request into `main`:
   ```bash
   git add <files>
   git commit -m "harness: add main.py pipeline loop"
   git push -u origin <your-name>/<short-topic>
   ```
   In the PR, say what changed, how you tested it, and which model you used if LLM calls were involved.
7. Get at least one teammate's review before merging.

### Before you push

- [ ] `cd framework && lake build && lake env lean Test.lean` passes if you touched `framework/`.
- [ ] No `sorry` in committed Lean code.
- [ ] Harness changes run from inside `harness/` without import errors.
- [ ] `git status` shows no `.env` and no real keys in `.env.example`.

### Conventions

**Lean (`framework/`)**
- Lean core only, no Mathlib.
- Put new definitions in the right module (`Contract`, `Soundness` or `Tactics`) and re-export new modules from `ContractForge.lean`.
- Every definition and theorem gets a `/-- doc comment -/`.
- Don't rename `Contract`, `Satisfies`, `Compatible`, `Refines`, `seq` or `discharge_po`. The agent prompts depend on these names, so a rename also needs a prompt update.

**Python (`harness/`)**
- Put settings in `config.py` and make them overridable by `CF_*` env vars, not hard-coded in other modules.
- New agents reuse `generate_verified` from `agents/base.py` rather than writing their own retry loop.
- New LLM providers go in `llm.py` plus the `MODELS`, `BASE_URLS` and `API_KEY_VARS` tables in `config.py`.
- If you change an agent's system prompt, record why in MEMORY.md and how it affected success rate or attempts.

**Commit messages:** prefix with the area: `framework:`, `harness:`, `agents:`, `benchmark:`, `eval:` or `docs:`.

### Secrets

- Never commit `.env` or put real keys in `.env.example`.
- If a key is ever committed, revoke it at the provider immediately. Deleting the commit isn't enough.
