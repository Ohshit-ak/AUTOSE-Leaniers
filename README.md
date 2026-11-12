# AUTOSE-Leaniers — ContractForge

ContractForge is a multi-agent pipeline that turns an English requirement into
**formally verified Lean 4 code**. Each layer is checked by Lean before the
next one starts:

```
English requirement
   │  L0 spec agent        → Lean spec  (Spec : Contract Input Output)
   ▼
Lean spec
   │  L1 architect agent   → component contracts; PO1, PO2
   ▼
Contracts (locked)
   │  L2 coding agents     → implementations (one per component); PO3
   ▼
Verified system  (Contract.system_sound ⇒ end-to-end correctness)
```

In L1 and L2 the model writes definitions (contracts, functions). The proof-obligation
statements are written by the harness, which also proves them and reports the part that fails.
There are two L1/L2 paths: per component group from a requirements graph (`--until arch`,
`--until code`) and per spec (`--until chain`). The last step of the intended pipeline, turning
the verified Lean implementation into Python, is not built yet.

> Current status, design decisions and next steps are in **[MEMORY.md](MEMORY.md)**. Read it first.

**Status (2026-11-12; Qwen results are from 2026-11-06).** All three layers run end to end with an open-weight model
(Qwen 2.5 7B, local). Single runs, seed 42, on the L0 specs that passed every L0 check:

| SRS | L0 specs into L1 | L1 (PO1+PO2) | L2 components (PO3) | Fully verified end to end |
|-----|------------------|--------------|---------------------|---------------------------|
| `0000 - gamma j` | 61 of 74 | 29/61 | 48/58 | **19/61** |
| `2009 - video search` | 14 of 21 | 9/14 | 16/18 | **7/14** |

"Fully verified" means that Lean re-checks the spec, both component contracts, PO1, PO2,
both implementations and their PO3 proofs together in one file. Known limits: 15 of these
26 split off a first component that only copies fields; none of the 17 data constraints
decompose (a single validity check); L2 often proves only one of the two components.
Details are in [MEMORY.md](MEMORY.md) under *L1/L2 end-to-end*.

**2026-11-12, chain-v3 (code changed, Qwen not rerun yet).** The table above is the v2 run.
Judged by the v3 checks, the 38 architectures v2 accepted on both SRSs are 21 single-step specs
(now not split at all), 16 identity / copy-of-`Spec` splits (now rejected) and 1 real
decomposition, so the v2 L1 numbers overstate decomposition. v3: the model writes only
definitions and the harness states and proves PO1/PO2/PO3; single-step specs keep `Spec` as their
one component; the chain path is a `main.py` stage with repetitions. New numbers need
`runs/qwen-chain-v3.sbatch` on a GPU node. See MEMORY.md, *chain-v3*.

---

## Branches (and where to go if `main` breaks)

Everything was merged into `main` on 2026-11-06 (PRs #1 and #2). The old branches are
kept on purpose, so each one is a known working state you can fall back to:

| Branch | What it has | Use it when |
|--------|-------------|-------------|
| `main` | everything: L0 v10.1, graph L1 + its Qwen runs, graph L2 (`code` stage), the per-spec L1/L2 path (`--until chain`; `e2e_l1l2.py` is its older CLI) and its v2 runs, the mid-submission report | normal work |
| `backup/main-pre-merge` | `main` as it was just before the 2026-11-06 merges (= `feat/l2-coding-agent`) | the merge itself turns out to have broken something |
| `l0-v10` | L0 frozen at v10.1 + the per-spec L1/L2 path and its e2e runs (here the agents are still called `architect_agent.py` / `coding_agent.py`) | the per-spec L1/L2 or `e2e_l1l2.py` stops working on `main` |
| `feat/l2-coding-agent` | graph L1 + the L2 coder for graph architectures (`code_lean.py`, `--until code`), no L1 run outputs | the graph L1/L2 code (`main.py --until arch/code`) stops working |
| `l1_runs` | graph L1 + the Qwen L1 runs (graph vs no-graph, 3 seeds) | you need the L1 runs as they were produced |
| `fix/l0-spec-quality` | early L0 work (repair loop, negative check), long since included everywhere | only for history |

What changed in the merge, in case something looks off:
- `main` and `l0-v10` each had their own L1/L2 agents. On `main` the graph-path agents keep the
  names `agents/architect_agent.py` and `agents/coding_agent.py` (used by `main.py`); the per-spec
  agents from `l0-v10` live in `agents/chain_architect.py` and `agents/chain_coder.py` (used by `main.py --until chain` and `e2e_l1l2.py`; rewritten on `main` for chain-v3, so the `l0-v10` copies are the v2 agents).
- A stray gitlink `AUTOSE-Leaniers` (a nested copy of the repo) from `l1_runs` was left out.

To fall back, don't rewrite `main`. Check the branch out on its own, or copy one file back:

```bash
git fetch origin
git switch l0-v10                                   # work from that branch
git restore --source origin/l0-v10 -- harness/e2e_l1l2.py   # or take one file from it onto main
git diff origin/backup/main-pre-merge main -- harness/      # see what the merge changed
```

After the merge, `lake build` succeeds and all 128 tests in `harness/tests` pass on `main`.
`harness/tests/` is a package (`__init__.py`) and `harness/pytest.ini` pins `testpaths`/`pythonpath`,
so an unrelated top-level `tests` package installed elsewhere in your Python can no longer
shadow ours. Run `python -m pytest` (or `python -m unittest discover -s tests`) from `harness/`.

---

## Repository layout

```
AUTOSE-Leaniers/
├── README.md               # this file: what it is, how to navigate, how to use
├── MEMORY.md               # project state, decisions, gotchas, next steps
├── .env.example            # API key names (copy to .env)
├── requirements.txt        # Python dependencies (pip install -r requirements.txt)
├── .env                    # your API keys (gitignored)
├── lakefile.lean           # root Lake workspace: requires framework/, so editors and
├── lean-toolchain          #   `lake env lean` resolve `import ContractForge` for runs/
├── lake-manifest.json      #   (generated by `lake update`)
│
├── framework/              # Lean 4 library (built with lake)
│   ├── lakefile.lean
│   ├── lean-toolchain      # Lean 4.29.1
│   ├── ContractForge.lean  # re-exports the modules below
│   ├── ContractForge/
│   │   ├── Contract.lean   # Contract type, PO1/PO2/PO3 definitions, seq composition
│   │   ├── Soundness.lean  # seq_sound, refines_sound, system_sound
│   │   ├── Strings.lean    # decidable string-format helpers for specs (allDigits, isMMYY, …)
│   │   ├── Tactics.lean    # discharge_po / discharge_po [names] tactics
│   │   └── Chain.lean      # compat_seq, chain3_sound: chains of n components (L1)
│   └── Test.lean           # smoke test
│
├── harness/                # Python orchestration
│   ├── main.py             # pipeline entry point: parse → spec (L0) → check → graph → arch (L1) → code (L2); or → chain
│   ├── chain_pipeline.py   # chain path (`--until chain`): per spec L1 → L2 → end-to-end theorem
│   ├── chain_checks.py     # chain L1 checks: shape, field visibility, identity/copy, strength, PO1/PO2 + diagnosis
│   ├── chain_failures.py   # failure classes of chain L1/L2 results; root cause of an unimplementable contract
│   ├── po.py               # PO code shared by both L1/L2 paths: forbidden words, statements, batched proving
│   ├── e2e_l1l2.py         # older CLI of the chain path (one run folder, shardable)
│   ├── req_graph.py        # L1: deterministic requirements graph (no LLM)
│   ├── arch_lean.py        # L1: harness-written Lean (message type, SystemSpec, PO statements)
│   ├── code_lean.py        # L2: harness-written Lean for the coding stage
│   ├── config.py           # models, API keys, retry/timeout settings
│   ├── llm.py              # call_llm(): DeepSeek / Groq / Gemma / Qwen; extract_lean()
│   ├── lean_runner.py      # check_lean(): type-checks code against the framework
│   ├── req_parser.py       # SRS XML → requirements JSON (rule-based, no LLM)
│   ├── validate.py         # L0.5: rule-based checks of generated specs, report, review.json
│   ├── tests/              # unit tests (parser, negative check, harness regressions)
│   └── agents/
│       ├── base.py             # generate → check → repair loop (staged, guarded)
│       ├── repair.py           # Lean errors → short feedback + fix hints
│       ├── fixups.py           # mechanical syntax fixes before each check
│       ├── spec_agent.py       # L0: requirement → spec
│       ├── arch_tools.py       # L1: the architect's tools (checks, obligations, submit)
│       ├── architect_agent.py  # L1 (main.py): group → component contracts + trace/PO1/PO2
│       ├── coding_agent.py     # L2 (main.py): component contract → impl + PO3
│       ├── chain_architect.py  # L1 (chain): spec → `Mid` + two chained contracts; PO1/PO2 by the harness
│       ├── chain_coder.py      # L2 (chain): contract → implementation; PO3 by the harness
│       └── autoprove.py        # generic proof search over model-written PO theorems (kept for other callers)
│
├── scripts/
│   ├── start_qwen_server.sh  # local Qwen 2.5 7B via llama.cpp (port 8082)
│   ├── usage_guard.sh        # stops a run above 75% GPU memory / job RAM
│   └── compare_runs.py       # before/after report of two single runs (v9 and earlier)
│
├── evaluation/
│   ├── compare_runs.py       # compare two runs over repetitions (rep1..N): mean (min–max), verdict only beyond the spread
│   └── summarize_e2e.py      # chain runs: results by mode, failure classes, 1-of-2 causes, spread over repetitions
│
├── Requirements/           # input SRS documents (.xml, .pdf)
│   └── parsed/             # parser output, one JSON per document
│
└── runs/                   # pipeline outputs: runs/<document>/<run-name>/
    │                       #   SRSs run so far: `0000 - gamma j`, `2009 - video search`
    └── logs/               # sbatch files of the e2e runs (logs themselves are not committed)
```

Planned, not yet created: `harness/reverify.py` and the
contents of `benchmark/` and the rest of `evaluation/` (see [MEMORY.md](MEMORY.md)).

### Where to look for…

| I want to… | Go to |
|------------|-------|
| Understand the core types and proof obligations | [framework/ContractForge/Contract.lean](framework/ContractForge/Contract.lean) |
| See why the pipeline is sound | [framework/ContractForge/Soundness.lean](framework/ContractForge/Soundness.lean) |
| Change the automatic proof tactic | [framework/ContractForge/Tactics.lean](framework/ContractForge/Tactics.lean) |
| Run the pipeline | [harness/main.py](harness/main.py) |
| Change how requirements are extracted from the SRS | [harness/req_parser.py](harness/req_parser.py) |
| Switch models or change retries/timeouts | [harness/config.py](harness/config.py) |
| Add a new LLM provider | [harness/llm.py](harness/llm.py) |
| Change how Lean is invoked or errors are reported | [harness/lean_runner.py](harness/lean_runner.py) |
| Edit an agent's system prompt | [harness/agents/](harness/agents/) |
| Change the retry/repair loop | [harness/agents/base.py](harness/agents/base.py) |
| Change how the requirements graph is built (L1) | [harness/req_graph.py](harness/req_graph.py) |
| Change the L1 tools, checks or generated Lean | [harness/agents/arch_tools.py](harness/agents/arch_tools.py), [harness/arch_lean.py](harness/arch_lean.py) |
| Run L1/L2 per spec on a finished L0 run | `main.py --until chain` ([harness/chain_pipeline.py](harness/chain_pipeline.py)) |
| Change what counts as a real decomposition, or the PO feedback | [harness/chain_checks.py](harness/chain_checks.py) |
| Change how PO statements are written or checked in batches (both paths) | [harness/po.py](harness/po.py) |
| Change how failures are classified, or the run summary | [harness/chain_failures.py](harness/chain_failures.py), [evaluation/summarize_e2e.py](evaluation/summarize_e2e.py) |
| Change the generic proof scripts for model-written theorems | [harness/agents/autoprove.py](harness/agents/autoprove.py) |

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

`lake env lean` only uses the Lake project in the **current directory**. To check a
generated spec, run it from the repo root (whose `lakefile.lean` requires `framework/`)
or point lake at it:

```bash
lake env lean "runs/0000 - gamma j/qwen-v6/lean/1.4_I3.lean"          # from the repo root
lake -d ~/AUTOSE-Leaniers env lean 1.4_I3.lean                         # from anywhere
```

Run inside `runs/.../lean/` without `-d`, it fails with
`unknown module prefix 'ContractForge'`.

**Editor (VS Code infoview):** open the repo root folder, not `runs/` or `framework/`,
and run *Lean 4: Server: Restart Server* once. The extension then finds the root
`lakefile.lean` and resolves `import ContractForge` for files under `runs/`.

### 2. Python

Python 3.10+. Use a venv (or your existing conda env):

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m spacy download en_core_web_sm   # L1 requirements graph
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
| `CF_GEMMA_MODEL` | `gemma-4-31b-it` |
| `CF_QWEN_MODEL` | `qwen2.5-7b-instruct` |
| `CF_MODEL` | `qwen` (default `--model` for `main.py`) |
| `CF_MAX_RETRIES` | `5` (Lean generate → check → repair attempts) |
| `CF_API_RETRIES` | `6` (retries on 429 / 5xx / network errors, with backoff) |
| `CF_LEAN_TIMEOUT` | `60` (seconds) |
| `CF_NEGATIVE_CHECK` | `1` (`0` turns off the L0 negative-case check) |
| `CF_NEG_ATTEMPTS` | `2` (tries to get a usable forbidden example from the model) |

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
See *Run local Qwen on ada* below for the one-time setup.

### Run local Qwen on ada

You have no sudo on ada, so everything goes in your home folder. Ollama's installer needs sudo; use llama.cpp instead.

**One-time setup, on `ada-gw1`:**

```bash
# model (~4.4 GB), at the path scripts/start_qwen_server.sh expects
mkdir -p ~/llm-models/qwen2.5-7b-instruct && cd ~/llm-models/qwen2.5-7b-instruct
for n in 00001 00002; do
  wget -c "https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m-$n-of-00002.gguf"
done

# cmake (pip isn't on PATH and conda needs its ToS accepted, so use python -m pip)
python -m pip install --user cmake
export PATH=$HOME/.local/bin:$PATH

# llama-server with CUDA
module load u22/cuda/12.4
git clone https://github.com/ggml-org/llama.cpp ~/build/llama.cpp && cd ~/build/llama.cpp
cmake -B build-cuda -DGGML_CUDA=ON -DGGML_NATIVE=OFF -DCMAKE_CUDA_ARCHITECTURES="61;75;80;86;89"
cmake --build build-cuda -j 8 --target llama-server

# project
cd ~/AUTOSE-Leaniers
python -m pip install openai python-dotenv google-genai
cd framework && lake build
```

`-DGGML_NATIVE=OFF` is required. Without it the binary is tuned to the login node's
CPU and crashes on GPU nodes with exit code `-4` (illegal instruction).
The CUDA architectures are listed because the login node has no GPU to detect (61 = GTX 1080 Ti).

**Each run, on a GPU node:**

```bash
sinfo -p u22 | grep idle                   # find a free node
srun -p u22 --gres=gpu:1 -c 8 --mem=16G --time=06:00:00 -w gnode005 --pty bash
tmux new -s qwen                           # keeps running after you disconnect (Ctrl-b d)
module load u22/cuda/12.4
cd ~/AUTOSE-Leaniers/harness
python main.py "../Requirements/0000 - gamma j.xml" --model qwen --limit 3   # quick test
python main.py "../Requirements/0000 - gamma j.xml" --model qwen --resume    # the rest
```

To stop a run automatically if GPU memory or the job's RAM goes above 75%:

```bash
python main.py "../Requirements/0000 - gamma j.xml" --model qwen & bash ../scripts/usage_guard.sh $! usage.log
```

`main.py` starts and stops the Qwen server itself. If it stops, the server log is
`runs/qwen_server.log`. Rerun with `--resume` to continue an interrupted run.
To get back into a running job: `squeue -u $USER`, then `ssh <node>` and `tmux attach -t qwen`.

### Type-check Lean code against the framework

```bash
python -c "from lean_runner import check_lean; print(check_lean('example : 1 + 1 = 2 := by decide'))"
```

It returns `{'success': True, ...}`, or `{'success': False, 'error': ...}` with
Lean's error message. A `sorry` counts as a failure. (Next to a real error, Lean's
"declaration uses `sorry`" warning only means the broken `def` was filled in by Lean.)

### Run the pipeline (`main.py`)

`main.py` parses every SRS XML in `Requirements/`, generates one Lean spec (L0)
per requirement, data constraint and use case, and then checks the specs (L0.5,
`validate.py`): no empty `post`, runtime bounds present, data-field specs accept and
reject values built from the parser's rules. L1 (`graph`, `arch`) and L2 (`code`) are described below.
A second, per-spec L1/L2 path is the `chain` stage (see *Chain path* below).

```bash
python main.py                                    # all XMLs, model qwen (or $CF_MODEL)
python main.py "../Requirements/0000 - gamma j.xml" --model gemma
python main.py --until parse                      # parser only, no model
python main.py --limit 5                          # first 5 entries
python main.py --only 5.1/R4 DD-user-id           # specific entries
python main.py --kinds data_constraint            # requirement | data_constraint | use_case
python main.py --resume                           # skip entries that already passed
python main.py --skip-lean                        # don't type-check (specs marked unchecked)
python main.py --until spec                       # stop after L0, skip the L0.5 checks
python main.py --on-l0-fail redo                  # redo L0 once for entries failing L0.5 (or: exclude, stop)
```

With `--model qwen`, the local server is started automatically if it isn't running
(GPU node required). Outputs:

| File | Contents |
|------|----------|
| `Requirements/parsed/<doc>.json` | parser output (requirements, data dictionary, use cases, dropped statements) |
| `runs/<doc>/<model>/specs.json` | summary + per entry: requirement text, prompt, Lean spec, `compiles`, `rejects_bad_example`, `bad_example`, `checked`, attempts, seconds |
| `runs/<doc>/<model>/lean/<id>.lean` | each Lean spec as a file; it starts with `import ContractForge`, so `lake env lean <file>` from the repo root checks it on its own. For a failed entry this is the attempt that got furthest (e.g. one that compiled but failed L0.5), not necessarily the last |
| `runs/<doc>/<model>/l05_report.md` | L0.5 verdict per entry: ✅ pass, ⚠️ flagged for review, ❌ fail, with reasons. Reports from runs up to `qwen-v7` contain false "`post` accepted every changed output" failures (a multi-line example input that didn't parse when pasted); fixed since, see MEMORY.md |
| `runs/<doc>/<model>/review.json` | decision per entry (accept / review / redo / exclude); edits you make are kept on reruns |
| `runs/<doc>/<run>/comparison.md` | written by `scripts/compare_runs.py`, not by `main.py`: totals, entries added/removed by the parser, improved/regressed entries and current L0.5 failures versus an earlier run |

To compare two runs of the same SRS (from the repo root):

```bash
python scripts/compare_runs.py "runs/0000 - gamma j/qwen-v8" "runs/0000 - gamma j/qwen-v9"
# → runs/0000 - gamma j/qwen-v9/comparison.md  (optional 3rd argument: output path)
```

Since v10, run each SRS several times and compare with `evaluation/compare_runs.py`
(a single run moves by ±5 L0.5 passes on its own):

```bash
cd harness && python main.py "../Requirements/0000 - gamma j.xml" --model qwen --repeat 3
# → runs/0000 - gamma j/qwen-v10.1/rep1..3/  (seeds CF_SEED, +1, +2; metadata in specs.json "meta")
cd .. && python evaluation/compare_runs.py "runs/0000 - gamma j/qwen-v8x3" "runs/0000 - gamma j/qwen-v10.1" -o report.md
```

Latest reports: [gamma j v8 ×3 → v10.1 ×3](runs/0000%20-%20gamma%20j/qwen-v10.1/comparison.md), [v10 → v10.1](runs/0000%20-%20gamma%20j/qwen-v10.1/comparison-vs-v10.md), [video search v8 → v10.1](runs/2009%20-%20video%20search/qwen-v10.1/comparison.md) (single runs). L0 is frozen at v10.1. Results per run are in [MEMORY.md](MEMORY.md).

`specs.json` is rewritten after every entry, so a crash or Ctrl-C loses nothing;
rerun with `--resume` to continue.

Per entry in `specs.json`:

| Field | Meaning |
|-------|---------|
| `compiles` | Lean accepts the spec and its satisfiability `example` |
| `rejects_bad_example` | `true`: Lean proved `post` rejects an output the requirement forbids (the model picks the forbidden example, the harness writes the statement). `false`: the spec accepts it. `null`: not run, or no usable example |
| `checked` | everything passed: compiles, the L0.5 hard checks, and the negative check |

None of these mean the spec matches the requirement, so read the generated specs as well.

Tests: `python -m unittest discover -s tests` (from `harness/`). They cover the parser,
the negative check, and harness regressions (`test_harness_fixes.py`: Lean extraction,
locked-example repair, `sorry` detection, best-attempt selection, the always-false-equation
and example-input checks, one-line witnesses for the vacuity check, the negative check's
reply forms, numeric data tests, fixups and repair hints) and the v9 changes (`test_v9_fixes.py`:
filter/sort/limit parsing, scope-section drops, `Nat ≥ 0`, per-mutant vacuity, the search template) and the v10 changes
(`test_v10_fixes.py`: seeds and run metadata, truncation, deriving fixup, rule-based negative cases, vacuity feedback,
`has_precondition`, UI drops, `ContractForge.Strings`, name suggestions, field and function-misuse hints). Tests that run Lean are skipped
if `lake` is missing. L1: `test_req_graph.py` (graph determinism, edges, cycles, unmapped fields; needs spaCy) and `test_arch.py` (every L1 tool on a toy shop, a correct architecture, the cases the harness rejects, and degraded operations). Chain path: `test_chain.py` (static checks, PO diagnosis, single-step routing, the coder, the pipeline with a scripted model, the repetition summary).

### L1: requirements graph → contracts (`--until graph`, `--until arch`)

L1 reads the **frozen** L0 run (default `runs/<doc>/qwen-v10.1/rep1`, change with `--l0-run`)
and never reruns L0. Needs spaCy: `python -m pip install spacy && python -m spacy download en_core_web_sm`.

```bash
cd harness
python main.py "../Requirements/0000 - gamma j.xml" --until graph                  # no model
python main.py "../Requirements/0000 - gamma j.xml" --until arch --repeat 3        # graph mode
python main.py "../Requirements/0000 - gamma j.xml" --until arch --repeat 3 --no-graph  # baseline
python main.py … --until arch --component AccountSys      # one group
python main.py … --until arch --arch-mode agent           # model calls the tools (needs CF_QWEN_JINJA=1)
cd .. && python evaluation/compare_runs.py "runs/0000 - gamma j/qwen-L1-v1-nograph" "runs/0000 - gamma j/qwen-L1-v1"
```

| Step | What | Where |
|------|------|-------|
| graph | `req_graph.py`, no model (graph version 2): entities from the SRS (data dictionary, glossary, actors) and from the L0 specs themselves (helper structures; state = a field one spec reads and another writes, e.g. `signedIn`), plus Domain.lean and `Requirements/synonyms/<doc>.json` when they exist (`--vocab srs` ignores both). One operation per L0 spec (Input fields = reads, Output fields = writes unless only copied or a `Bool` result), write→read and use-case edges, groups (connected), components (Louvain: always above `CF_GRAPH_MAX_COMPONENT`=8 ops, from `CF_GRAPH_MIN_SPLIT`=4 ops when modularity ≥ `CF_GRAPH_MIN_MODULARITY`=0.1). Cycles are listed and broken: components stay, the chain order with the least backward dataflow is taken and the backward edges are recorded (`CF_GRAPH_CYCLES=merge` for the v1 behaviour). `--until graph` always rebuilds | `runs/<doc>/graph/graph.json`, `graph.png` |
| arch | per group with ≥ 2 compiling L0 specs: the harness writes a message type (`req_<op>`/`res_<op>`), a locked `SystemSpec` (one case per L0 spec), every theorem statement; the model writes `<C>_pre_<op>`/`<C>_post_<op>` per operation. Checks: compiles, satisfiable on the L0 example, not vacuous, trace (covers the L0 spec), PO1 per consecutive pair, PO2 for the chain, `system_sound_<G>` | `runs/<doc>/<model>-L1-v1[-nograph]/rep<k>/arch/<group>/Arch.lean`, `arch.json`, `arch/summary.json` |

An operation whose contract fails a check or whose trace is not proved is **degraded**: it keeps
its L0 conditions as its contract (harness fallback), so it no longer blocks PO1/PO2 of the
group. The verdict is then `accepted-degraded` with the operations listed in `arch.json`
(`degraded`); `CF_ARCH_DEGRADE=0` restores the strict behaviour (verdict `rejected`).

`Arch.lean` compiles on its own from the repo root (`lake env lean "runs/…/Arch.lean"`);
obligations that were not proved are comments starting `-- NOT PROVED:`. `arch.json` has the
model's code, every obligation (proved, by `auto`/`model`, attempts, errors), contract checks,
the tool-call log, the mode used and `meta`. Design and results: MEMORY.md (*L1*).

### Chain path: L1/L2 per spec (`--until chain`)

The second L1/L2 path. It reads the **frozen** L0 run (default `runs/<doc>/qwen-v10.1/rep1`,
`--l0-run`) and sends every spec that is `checked` and accepted in `review.json` through L1 and L2.

```bash
cd harness
python main.py "../Requirements/0000 - gamma j.xml" --until chain --repeat 3     # seeds 42, 43, 44
python main.py … --until chain --only 5.3/R4 UC-customer-login-customer          # some specs
python main.py … --until chain --repeat 3 --fallback-single --run-name qwen-chain-v3-fallback
cd .. && python evaluation/summarize_e2e.py "runs/0000 - gamma j/qwen-chain-v3"  # results, failure classes, spread
```

On ada: `sbatch runs/qwen-chain-v3.sbatch` (both SRSs, 3 seeds, with and without fallback, summary).
`e2e_l1l2.py <run_dir> [--start A --end B]` is the older CLI of the same pipeline (one folder, shards).

| Step | Who writes what | Checks |
|------|-----------------|--------|
| route | harness (`chain_checks.single_step`) | a data constraint, or a `post` with one condition, is **not split**: its one component is `Spec`, PO2 is `Refines Spec Spec`, no model call (`mode: single`) |
| L1 | model: `structure Mid` and two contracts `Input → Mid → Output`, definitions only. Harness: the PO1/PO2 statements and proofs (`discharge_po1`, `discharge_po2`) | before Lean: shape; **visibility** (a contract reads only its own records; an `Input` field used by the second contract is reported with the field to add to `Mid`); **work** (a `post` that only copies fields or restates the precondition is an identity; a contract equal to `Spec` up to variable names is a copy; the second must use what the first computes). In Lean: a fact claimed about a copied `Input` field must follow from `pre`; PO1; PO2. A failed PO names the conjunct that does not follow |
| L2 | model: `def <C>Impl (x : A) : B` with the signature it is given. Harness: PO3 statement and proof (`discharge_po3`) | signature; PO3, and on failure the `post` conjuncts the function does not establish |
| end | harness | one file per spec with `theorem system_ok : Spec.Satisfies (<B>Impl ∘ <A>Impl)` from `Contract.system_sound po1 po2 …` (or `refines_sound` for a single component), checked by Lean (`full_check`) |

`--fallback-single`: when the two-component split fails, `Spec` is implemented as one component
(`mode: single-fallback`, reported separately; keep these runs in their own `--run-name`).
`--split always|never` overrides the routing.

Outputs in `runs/<doc>/<model>-chain-v3/rep<k>/`:

| File | Contents |
|------|----------|
| `l1l2.json` | per spec: `l1` (success, `mode`, attempts, contracts, `strength`, error, `error_class`, code), `l2` per contract (success, attempts, error, `error_class`, code), `full_check`, `system_theorem`, `l2_root_cause` |
| `l1l2/<id>.lean` | spec + architecture + implementations + `system_ok`, checkable with `lake env lean` from the repo root |
| `chain_meta.json` | model, seed, prompt hashes, commit, L0 run, options |

`strength` (chain architectures) records what the decomposition adds to `Spec`: first component
does work, second does work, second uses the first's result, neither is a copy of `Spec`, the
second states an interface assumption (score out of 5; the first four are required).
`error_class` (`harness/chain_failures.py`): shape, visibility, identity, unrealizable, po1, po2,
signature, po3, or a Lean class (redeclared, unknown-field, unknown-name, syntax, type-error,
proof). `summarize_e2e.py` counts them, lists specs with one of two components implemented with
the cause, and prints `mean (min–max)` over repetitions.

### Writing Lean against the framework

```lean
-- import ContractForge / open ContractForge are added for you by check_lean
def incC : Contract Nat Nat := { pre := fun _ => True, post := fun x y => y > x }

theorem inc_ok : incC.Satisfies (· + 1) := by
  unfold incC; discharge_po

-- or let the tactic unfold your own definitions too:
theorem inc_ok' : incC.Satisfies (· + 1) := by
  discharge_po [incC]
```

`discharge_po` unfolds the PO definitions and tries `simp_all`, `omega`,
`grind` and `decide`. It does **not** unfold your own contracts, so without an
`unfold` first their `pre`/`post` stay opaque and it fails. `discharge_po [A, B, Spec]`
also unfolds the named definitions. One tactic per obligation goes further:
`discharge_po1 [A, B]` (PO1), `discharge_po2 [A, B, Spec]` (PO2: it takes the middle value of
`A.seq B`, an `∃` hypothesis, apart before closing), `discharge_po3 [C, CImpl]` (PO3: splits an
`if` in the implementation). If none closes the goal, write the proof by hand.

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
