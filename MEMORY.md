# MEMORY.md — Project State & Decisions

A running log of where ContractForge stands, why things are the way they are,
and what comes next. Update it whenever you finish a piece of work or make a
decision someone else would need to know.

## Status (2026-10-31)

| Part | State |
|------|-------|
| `framework/` (Lean library) | Done for v0. Builds with `lake build`; `Test.lean` smoke test passes. |
| `harness/config.py` | Done. Models, keys, retries, timeouts, API retry count (`CF_API_RETRIES`). |
| `harness/llm.py` | Done. DeepSeek / Groq / Gemma / local Qwen. Retries transient API errors (429, 5xx, network) with exponential backoff (10s → max 120s). |
| `harness/lean_runner.py` | Done. `sorry` detection fixed 2026-10-31 (see *v7*). |
| Repo-root Lake workspace | Added 2026-10-31 (uncommitted at time of writing): `lakefile.lean` (`require contractforge from "framework"`), `lean-toolchain`, `lake-manifest.json`, so editors resolve `import ContractForge` for files under `runs/`. |
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
| Qwen 2.5 7B (local) | 75 | **No** (`--skip-lean`) | **0/75 compile** (checked by hand 2026-10-30) | removed from the tree 2026-10-31 (still in 2373f8e) | Old prompt, no repair loop. Errors: Lean 3 syntax (`λ x,`, `begin…end`, `refl`), redefining `Contract` with one type parameter (→ "Function expected at `Contract Nat`"), `Spec x y` applied as a function, unsolved goals. |
| Qwen 2.5 7B on ada, prompt v1 | 75 | Yes | **30/75 (40%)**: requirements 20/35, data constraints 1/20, use cases 9/20 | `runs/0000 - gamma j/qwen-baseline/` | 2026-10-30 hardened prompt, old repair loop. 28/30 passes on attempt 1; repairs almost never helped. |
| Qwen 2.5 7B on ada, prompt v2 + new repair loop | 75 | Yes | **55/75 (73%)**: requirements 29/35, data constraints 10/20, use cases 16/20 | `runs/0000 - gamma j/qwen-v2/` | 2026-10-31. 42 pass on attempt 1, 13 after repair. 32 newly pass, 7 regress vs v1. ~18 min, peak 43% GPU memory. Remaining errors: invented API (`List.nodup`, `String.last`, `String.toInt`, `Char.isAlphabetic`), example values that make the spec false, fields missing from `Input`, `!`/`exists` syntax. 9/45 non-data passes have `pre := True`. |
| Qwen 2.5 7B on ada, v3: staged repair + L0.5 | 75 | Yes + L0.5 | **58/75 compile; L0.5: 37 pass, 21 flagged, 17 fail** (v2 under the same checks: 55 compile, 38 pass) | `runs/0000 - gamma j/qwen-v3/` | 2026-10-31. Name errors 8→2, syntax 4→2; 10 newly compile, 7 regress (single run each, so partly noise). 2 entries crashed: request > 8192-token context (bigger prompt + repair history). Money fields still parsed from strings: the data-field template says `raw : String`, which conflicts with the "money → Nat cents" rule. |
| Qwen 2.5 7B on ada, v4: fixes to v3 | 75 | Yes + L0.5 | **65/75 compile** (requirements 29/35, data 17/20, use cases 19/20); **L0.5: 45 pass, 20 flagged, 10 fail** | `runs/0000 - gamma j/qwen/` (+ `l05_report.md`, `review.json`) | 2026-10-31. Server context 16384 (no more overflow crashes); numeric data fields use `value : Nat` (money in cents); harness witness search found example values 9 times; use cases with preconditions must not have `pre := True`. 10 newly compile, 3 regress. Remaining: 4 type errors, 3 invented names/fields, 2 vacuous `post`, 1 proof. 15 flags are `pre := True` (mostly performance requirements, which really have no precondition). |
| Qwen 2.5 7B on ada, `qwen-v5/` and `run-02/` | 75 | Yes + L0.5 | same as v4 (65/75; 45/20/10) | `runs/0000 - gamma j/qwen-v5/`, `run-02/` | **Not v5.** Same Lean files as v4 and no `compiles`/`rejects_bad_example` fields, so they came from the v4 code (seed 42 makes reruns deterministic). |
| Qwen 2.5 7B on ada, v6: v5 code (negative check, empty-reply retry) | 75 | Yes + L0.5 + negative check | **64/75 compile, 60/75 checked** (requirements 30/35, data 17/20, use cases 17/20 by compile); **L0.5: 42 pass, 18 flagged, 15 fail**; **`rejects_bad_example` null for all 75** | `runs/0000 - gamma j/qwen-v6/` | 2026-10-31, job 50923 on gnode007 (1080 Ti), 24 min of model time vs 15 for v4, 2.29 attempts per entry vs 1.92. 4 newly pass (1.4/I3, 1.4/S3, CI-1, sales-person login), 9 regress (5.3/R1, 5.3/R5, 5.5/R2, 5.5/R5, customer login, add-to-cart, remove-user, change-user-properties, remove-plug-ins). The negative check never gave a verdict, so it added cost without catching anything. Cause (diagnostic on 8 entries, `runs/negdiag/`): Qwen keeps `IN`/`OUT` as literal names and binds them with `let IN := {…}` inside the proof, so `negative._bad_values` (which only accepts `Spec.post {…} {…}` inline) finds no values and every reply counts as `bad_example`. |
| Qwen 2.5 7B on ada, v7: harness fixes (single Lean block, best attempt returned, `sorry` detection, contradiction checks, self-containing-structure rules) | 75 | Yes + L0.5 + negative check | **64/75 compile, 57/75 checked** (requirements 30/35, data 17/20, use cases 17/20; same as v6); **L0.5: 42 pass, 15 flagged, 18 fail** (v6: 42/18/15); `rejects_bad_example` still null for all 75 | `runs/0000 - gamma j/qwen-v7/` | 2026-10-31, job 51118 (1080 Ti), 28 min of model time (v6 24), 2.60 attempts per entry (v6 2.29). No duplicate `Input`/`Output`/`Spec` declarations any more. Compile: 6 newly compile (3.2.3/S1, 5.3/R5, 5.5/R5, DD-shipping-date, add-to-cart, change-user-properties), 6 regress (1.4/I3, 3.3.3/S3, 3.5.3/S2, DD-item-name, checkout, sales-person login). 11 newly pass L0.5, 11 no longer pass. **All 7 L0.5 failures that aren't compile errors are false alarms** (3.1.3/S2, 3.2.3/S2, 3.4.3/S1, 5.3/R1, 5.5/R2, add-user, remove-plug-ins), and so are all 4 in v6: a vacuity-check bug, see *Gotchas*. With that fixed, about 64/75 would pass every check (v6 about 64 too), and every remaining failure is a compile error. The false alarms are also fed back into the repair loop, which probably explains part of the extra attempts and some regressions. Of the 11 that don't compile, 3 are logins that use `i.accounts` without declaring an `accounts` field in `Input` (3.1.3/S3, customer login, sales-person login), 3 use APIs that don't exist (`Function.sum`, `String.substring`, `String.splitOn` treated as a list), 2 are type errors (`LE (Nat × Nat)`, `HAppend` with a proof-dependent list), 2 reference fields that were never declared, and 1 is a `decide` failure on `String.all`. |
| Gemma (`gemma-4-31b-it`) | 4 (`1.4/I3`, `1.4/S2`, `1.4/S3`, `1.4/S4`) | Yes | 4/4 pass, mean 1.5 attempts, 2–5.5 min each | removed from the tree in dd67bca (still in 61ac8dc) | First run with the hardened prompt. Slow because of API retries. Compile ≠ correct: S2 ignores "initial", I3 doesn't say which orders get confirmed. |

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
- **L0 prompt v2 + repair loop (2026-10-31)**, because v1 passed 30/75 and repairs almost never fixed anything:
  - prompt: `deriving DecidableEq, Repr` on every structure; values built with named fields `{ f := … }`, never `⟨…⟩`; prove the example with `by unfold Spec; decide` (`decide` alone can't see through `Spec`, and `simp [Spec]` fails on strings); strings inspected via `.toList` (`String.all` doesn't evaluate under `decide`); a whitelist of core functions checked with `#check` on 4.29.1 and a list of ones that don't exist; no recursion; keywords banned as field names; three compiling templates (requirement, data field, use case);
  - repair loop (`agents/base.py`, `agents/repair.py`): repairs are a conversation (original request + last 2 attempts); Lean output is cut to the first 3 errors, each with its line of the model's code and a hint chosen by error type (e.g. the real fields of `Input`, `String.forall` → `s.toList.all`); if the same error repeats, start over at temperature 0.7 (`CF_RESTART_TEMPERATURE`).
  - Result: 30/75 → 55/75.
- **v3 (2026-10-31): staged repair + L0.5 (`validate.py`, `main.py` stage `check`).** Repairs show only the earliest error layer (syntax → names → types → proof); mechanical fixes (`agents/fixups.py`) run before each check; when only the `example` is wrong the definitions are locked and the model writes new values, told which `∧`-part its values break; a repair that weakens the spec (`pre`/`post` → `True`, `post` ignores `o`) is rejected; unknown names get "did you mean" from Lean's own name list (`lean_runner.core_names`, cached in `framework/.lake/`); prompt adds a type table and "specify what, not how" with `-- IMPL:` comments for requirements that prescribe a method. L0.5 checks: housekeeping, vacuity (`post` must reject a changed output), parser facts (runtime fields/bounds), data tests built from the parser's length/charset/format rules. Hard L0.5 problems are fed back into the repair loop; `--on-l0-fail stop|redo|exclude`.
- **v4 (2026-10-31):** Qwen server context raised to 16384 (`CF_QWEN_CTX`; 8192 overflowed with repair history, peak GPU memory 47%); a conversation that still overflows is retried without history. When only the example is wrong, the harness searches for example values itself (`validate.find_witness`: values from the spec's own numbers/strings and strings of the lengths it mentions); if none exist the spec is treated as contradictory and the model must fix `pre`/`post`. Numeric data fields (parser `type: money`, `default`, `max_ref`) get `value : Nat`. `--only`/`--kinds`/`--limit` keep other entries in `specs.json`. `scripts/usage_guard.sh` stops a run above 75% GPU memory or job RAM.
- **v5 (2026-10-31, branch `fix/l0-spec-quality`): negative-case check + stricter prompt.** Why: the qwen-v3 login spec (`post := o.signedIn = true ∧ o.cookie.isSome = true`) compiled and passed L0.5, yet every login succeeds, wrong password included; nothing tested what `post` must reject.
  - **Negative check** (`agents/negative.py`, run as the last validator in `generate_verified`): once a spec compiles and passes the hard L0.5 checks, the model names one input satisfying `pre` and an output the *requirement* forbids. The harness writes the statement itself and Lean must prove `Spec.pre IN` and `¬ Spec.post IN OUT`. If `decide` proves `post` true, the repair loop gets "your spec accepts a forbidden behaviour …"; a repaired spec must first reject that same example. Unusable examples (wrong fields, input outside `pre`, empty reply, API error) never block a spec. `CF_NEGATIVE_CHECK=0` turns it off; `CF_NEG_ATTEMPTS` (2) tries per spec.
  - The bad-example prompt must say outright that OUT is the *wrong* answer (e.g. wrong password → signed in). With a vaguer prompt, Gemma 26B returned the correct refusal instead (wrong password → not signed in); the old spec rejects that, so the check passed it.
  - **Prompt:** `post` must say *when* the success and failure outcomes happen (`↔` / `if`); state the decision depends on (accounts, stock) goes in `Input` (helper structures and `List <Structure>` allowed); `String.all` doesn't reduce under `decide`; Lean core only. New template: login with `o.signedIn = true ↔ ∃ a ∈ i.accounts, …` (`∃ a ∈ xs` decides on 4.29.1).
  - **Outputs:** `specs.json` has `compiles` and `rejects_bad_example` (`true`/`false`/`null`) plus `bad_example`; `checked` still means everything passed. Saved `lean/<id>.lean` files start with `lean_runner.HEADER`, so they compile on their own. L0.5 review and the report's "Compiles" now use `compiles`.
  - `validate.example_errors` returns Lean errors per extra example. A failed Lean run without a positioned error (e.g. a timeout) used to count every example as passing; it now counts as failing.
  - **Tested:** `tests/test_negative_check.py` (8 Lean-only tests: the old login spec is caught, the account-based one passes, unusable examples don't block). With Gemma 26B on the real qwen-v3 login spec: `accepts_forbidden` with "wrong password → signed in".
- **v6 failures checked by hand (2026-10-31).** Recompiling all 75 `qwen-v6/lean/*.lean` files gives the same 64/11 as the `compiles` headers. Of the 11 failures, 4 use names that don't exist in Lean 4 (`List.nth?`, `String.substring`, `List.nodup`, `.map` on a function), 4 are type errors, and 3 are prompt gaps (items 9–11 below). Two (`5.3_R5`, `DD-credit-card-expiry-date`) declared `Input`/`Output`/`Spec` twice because of a harness bug, and two (`3.1.3/S3`, `5.3/R5`) had compiled at an earlier attempt but the broken last attempt was saved.
- **v7 harness fixes (2026-10-31; run as `qwen-v7`, see the L0 table).** Tests: `harness/tests/test_harness_fixes.py` (16 tests; whole suite 30, passing).
  - `llm.extract_lean` keeps only the last ```lean block that defines `Spec` (else the last block). It used to join every block, so a draft + correction declared everything twice.
  - Example-only repair (`base.with_locked_defs`): if the reply has no `example`, keep the previous one instead of appending the whole reply to the locked definitions.
  - `lean_runner.check_lean` matches ``declaration uses `sorry` `` (backticks, Lean 4.29) as well as the old `'sorry'`. Before, a `sorry` proof exits 0 and passed.
  - `generate_verified` returns the attempt that got furthest (compiles-but-fails-L0.5 > Lean error > weakened), not the last one, and logs `{"stage": "returned", "attempt": N}`.
  - Prompt rules: a structure must never contain itself (store trees flat with `id`/`parent : Option Nat`; Lean can't derive `DecidableEq` for `List Category` inside `Category`); a changing value is a field of both `Input` and `Output` linked as `o.x = i.x + 1`, never `x + 1 = x`; the example's `Spec.post` input must be exactly the `Spec.pre` input.
  - `validate.check_contradictions` (`x + n = x` / `x = x + n`, same `x`) and `check_example_inputs` run first in `hard_checks`; the contradiction check is also appended to the feedback when Lean fails, since `5.3/R5`'s `a.failedAttempts + 1 = a.failedAttempts` fails inside `decide` where `hard_checks` never runs. Neither flags any currently compiling spec in any run.
  - Repair hints (`agents/repair.py`): "None of the deriving handlers" on a self-containing structure → flat id/parent layout; "has already been specified" / "Fields missing" → reuse the `Spec.pre` input record and list every structure's fields.
  - Still open: the 4 invented-name failures need entries in the prompt's "don't exist" list / `MISSING_API`.
- **Requirements parser is rule-based and must stay AI-free.** Same XML bytes → same JSON bytes (tested across hash seeds). Every dropped statement is kept in `dropped` with the rule that removed it; tune the word lists at the top of `req_parser.py`, not ad hoc.
- **Performance requirements are kept**, tagged `verification: "lean+python_runtime"`. Bounds are integers (µs, per-second, counts) so a Python-measured value can be checked against the Lean spec with `decide`.
- Module is `req_parser.py`, not `parser.py`: Python 3.9 ships a stdlib `parser` module.
- **Local Qwen (`model="qwen"`)** = Qwen 2.5 7B GGUF via llama.cpp `llama-server` on **port 8082** (`scripts/start_qwen_server.sh`). Kept isolated from other projects on ada: own port (8080 vrspecml, 8081 housing-trends), own `CF_`-prefixed env vars, own `venv/` inside this repo; the shared model file and binary are only read.
- **Qwen on an ada GPU is the main L0 model now** (2026-10-31). With a GPU it takes seconds per entry; Gemma 26B over the API took ~140 s per call. Setup is in the README (*Run local Qwen on ada*).

## Proof obligations (naming used everywhere)

- **PO1** `Contract.Compatible c₁ c₂` — c₁'s guarantee meets c₂'s assumption.
- **PO2** `Contract.Refines c s` — composed contract refines the spec.
- **PO3** `Contract.Satisfies c f` — implementation meets its contract.
- `Contract.system_sound` combines PO1 + PO2 + PO3 into end-to-end correctness.

## Gotchas

- Run harness code from inside `harness/` (modules import each other as `from config import ...`).
- Run `lake build` in `framework/` once before the harness, or `import ContractForge` won't resolve (`main.py` builds it on first run).
- **`lake env lean <file>` only uses the Lake project in the current directory.** Run inside `runs/.../lean/` it finds none and fails with "unknown module prefix 'ContractForge'". Run from the repo root or `framework/`, or use `lake -d <repo root> env lean <file>`. In VS Code, open the repo root folder (the root `lakefile.lean` makes the infoview resolve the import) and restart the Lean server.
- **Lean marks a broken `def` with `sorry`.** "declaration uses `sorry`" next to a real error is a side effect, not the model writing `sorry`.
- **A real Gemini key was committed to `.env.example` in `dd2bdfe` and pushed to GitHub.** The working copy is now blanked, but the key is still in history: **revoke it in Google AI Studio** and put a new one in `.env`.
- `Requirements/parsed/0000 - gamma j.json` committed in 2573d72 was parsed from an older XML; re-parsing the current XML only changes `source.sha256`.
- Run logs (`runs/*.log`, e.g. `runs/qwen_server.log` written by `main.py`) are gitignored.
- **One negative example is a weak test.** The model picks it, and may pick an easy one the spec happens to reject; `rejects_bad_example: true` is evidence, not proof, that `post` is tight. It also only catches a `post` that accepts too much, not one that rejects correct outputs.
- **L0.5 "`post` accepted every changed output" was a false alarm in every case so far (found 2026-10-31).** `validate.check_vacuity` pastes the example's input record from `example_witness` into a new `example : ¬ (Spec.post {…} {…})`. When the model wrote that record across several lines, the pasted text doesn't parse in that position (`unexpected identifier; expected '}'`), the Lean run fails, and the failure is reported as a vacuous `post`. With the record on one line, all 11 flagged specs (v6: 4, v7: 7) reject the changed output. Until it is fixed, treat that L0.5 reason as unverified. The negative check (`agents/negative.py`) also depends on the example being in one exact form, so it probably has the same kind of bug.
- **Lean "checked" only means it compiles.** The `example` proves the spec is satisfiable, not that it matches the requirement. Vague requirements ("Confirm Orders") give specs that compile but say too little; review them by hand.
- **`gemma-4-31b-it` returned 500 INTERNAL on every call on 2026-10-30.** `gemma-4-26b-a4b-it` worked (`CF_GEMMA_MODEL=gemma-4-26b-a4b-it`), but at ~140 s per call.
- **ada setup (no sudo):**
  - Ollama's installer needs sudo, so don't use it; use llama.cpp.
  - `pip` isn't on PATH; use `python -m pip`.
  - Plain `conda install` fails until you accept Anaconda's ToS; use `--override-channels -c conda-forge`, or `python -m pip install --user cmake`.
  - CUDA comes from modules: `module load u22/cuda/12.4`.
- **Build llama.cpp with `-DGGML_NATIVE=OFF`.** A build on `ada-gw1` uses that CPU's instructions and crashes on the GPU nodes with exit code `-4` (illegal instruction). Also pass `-DCMAKE_CUDA_ARCHITECTURES="61;75;80;86;89"` (61 = GTX 1080 Ti, e.g. gnode005), because the login node has no GPU to detect.
- **Default `lake` on ada is Lean 4.35.0**; inside `framework/`, elan switches to 4.29.1 from `lean-toolchain`.

## Next steps

1. Revoke the leaked Gemini key.
1. v7 is done (`qwen-v7`, 64/75, same as v6). Next: when a spec uses a field `Input` doesn't declare (`i.accounts` in 3 logins), give a repair hint that adds the field to `Input`; add `Function.sum`, `String.substring` to the "don't exist" list; fix the vacuity-check bug (put the witness on one line in `validate.check_vacuity`/`example_witness`, add a regression test), then rerun as `qwen-v8`. Commit the v7 changes and the root Lake files.
2. Commit `runs/0000 - gamma j/qwen/` (prompt v2) and `qwen-baseline/` (v1). Next for L0: add the APIs Qwen still invents (`List.nodup`, `String.last`, `String.toInt`, `Char.isAlphabetic`) to the "don't exist" list and repair hints; look at the 7 entries that regressed.
3. Review the checked specs for meaning, not just compilation (see *Gotchas*).
4. Run Gemma (and DeepSeek/Groq if keys are available) on all 75 entries with `--resume` to get comparable L0 pass rates.
5. Wire L1 (architect) and L2 (coding) stages into `main.py`.
6. Add `requirements.txt` (`google-genai`, `openai`, `python-dotenv`).
7. First benchmark system: `benchmark/bank_ledger/`.
8. `evaluation/metrics.py` with the `RunResult` dataclass from the kickoff guide.
