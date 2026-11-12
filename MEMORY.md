# MEMORY.md — Project State & Decisions

A running log of where ContractForge stands, why things are the way they are,
and what comes next. Update it whenever you finish a piece of work or make a
decision someone else would need to know.

## Status (2026-11-12)

| Part | State |
|------|-------|
| `framework/` (Lean library) | Done for v0. Builds with `lake build`; `Test.lean` smoke test passes. |
| `harness/config.py` | Done. Models, keys, retries, timeouts, API retry count (`CF_API_RETRIES`). |
| `harness/llm.py` | Done. DeepSeek / Groq / Gemma / local Qwen. Retries transient API errors (429, 5xx, network) with exponential backoff (10s → max 120s). |
| `harness/lean_runner.py` | Done. `sorry` detection fixed 2026-10-31 (see *v7*). |
| Repo-root Lake workspace | Added 2026-10-31 (committed in c77afe4): `lakefile.lean` (`require contractforge from "framework"`), `lean-toolchain`, `lake-manifest.json`, so editors resolve `import ContractForge` for files under `runs/`. |
| `harness/req_parser.py` | Done (2026-10-28). SRS XML → requirements JSON, deterministic, no LLM. Tests in `harness/tests/`. |
| `harness/agents/spec_agent.py` (L0) | Done. Prompt hardened 2026-10-30 (see *Decisions*). Builds prompts from parser JSON (`spec_prompts`, `run_spec_from_json`). |
| `harness/agents/` L1 (`architect_agent.py`, `arch_tools.py`) | **Done, L1-v1 (2026-11-04)**, branch `l1-graph-contracts`. Pipeline mode (default) and agent mode; graph and `--no-graph`. Tested on a toy and with a copy-the-L0 fake model on gamma j; **not yet run with Qwen** (`runs/qwen-L1-v1.sbatch`). See *L1*. |
| `harness/req_graph.py` | Graph version 2 (2026-11-12, see *Graph v2*). Deterministic, no LLM; spaCy `en_core_web_sm` 3.8. The committed `runs/0000 - gamma j/graph/` is still version 1: rebuild with `--until graph`. |
| `harness/arch_lean.py` | Done (L1-v1). All L1 Lean the harness writes (message type, SystemSpec, contracts, statements, auto-proofs). |
| `framework/ContractForge/Chain.lean` | Done (L1-v1). `compat_seq`, `chain3_sound`; existing definitions unchanged. |
| `framework/ContractForge/Tactics.lean` | `discharge_po1`, `discharge_po2`, `discharge_po3` added 2026-11-12 (`discharge_po` unchanged). Run `lake build` in `framework/` after pulling. |
| `harness/agents/coding_agent.py` (L2) | Merged from `feat/l2-coding-agent` (PR #1): `code` stage in `main.py`, `code_lean.py`, tests. Not run through `main.py` yet. |
| `harness/main.py` | Single entry point. Stages `parse` → `spec` → `check` (L0) → `graph` → `arch` (L1); `--until graph/arch` read the frozen L0 run and never rerun L0. `code` (L2) reads the accepted L1 architectures. Auto-starts the Qwen server. |
| `harness/agents/chain_architect.py`, `chain_coder.py` (per-spec L1/L2) | **chain-v3 (2026-11-12), not yet run with Qwen** (see *chain-v3*). The model writes definitions only; the harness states and proves PO1/PO2/PO3. v2 was run end to end 2026-11-06 (see *L1/L2 end-to-end*). |
| `harness/chain_checks.py`, `chain_failures.py`, `po.py` | Done (chain-v3). Static checks + strength record + PO diagnosis; failure classes; PO code shared by both L1/L2 paths. |
| `harness/chain_pipeline.py`, `main.py --until chain` | Done (chain-v3). The chain path is a `main.py` stage with `--repeat`; `e2e_l1l2.py` is a thin CLI over the same code (shards). Job file: `runs/qwen-chain-v3.sbatch`. |
| `harness/reverify.py` | Not started. |
| `benchmark/gammaj/` | `GammaJ_L0.lean`: hand-written gold L0 (25 specs `Spec_<id>` (16 data dictionary, 3 cart, 4 use case, 1 business rule, 1 security), all with `_sat` witnesses, ambiguities marked), compiles. `Domain.lean`: **DRAFT, needs human review**, extracted from it (`Product`, `CartLine`, `Cart`, `Account`, `Order`, `qtyOf`, `itemCount`, `totalCost`; adds `deriving DecidableEq, Repr`). |
| `evaluation/compare_runs.py` | Done (v10; arch mode L1-v1). Compares two runs over repetitions, mean (min–max), verdict only beyond the spread. L1 folders get the arch report (now with `accepted-degraded` and degraded operations). |
| `evaluation/summarize_e2e.py` | Rewritten 2026-11-12. Chain runs: results by mode, failure classes for L1 and L2, the cause of every "one of two components" spec, mean (min–max) over `rep*/`. Works on the v2 runs too. |
| `framework/ContractForge/Strings.lean` | Done (v10), frozen. String-format helpers over `List Char`. |
| `requirements.txt` | Created 2026-11-12 (`pip install -r requirements.txt`). |

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
| Qwen 2.5 7B on ada, v7: harness fixes (single Lean block, best attempt returned, `sorry` detection, contradiction checks, self-containing-structure rules) | 75 | Yes + L0.5 + negative check | **64/75 compile, 57/75 checked** (requirements 30/35, data 17/20, use cases 17/20; same as v6); **L0.5: 42 pass, 15 flagged, 18 fail** (v6: 42/18/15); `rejects_bad_example` still null for all 75 | `runs/0000 - gamma j/qwen-v7/` | 2026-10-31, job 51118 (1080 Ti), 28 min of model time (v6 24), 2.60 attempts per entry (v6 2.29). No duplicate `Input`/`Output`/`Spec` declarations any more. Compile: 6 newly compile (3.2.3/S1, 5.3/R5, 5.5/R5, DD-shipping-date, add-to-cart, change-user-properties), 6 regress (1.4/I3, 3.3.3/S3, 3.5.3/S2, DD-item-name, checkout, sales-person login). 11 newly pass L0.5, 11 no longer pass. **All 7 L0.5 failures that aren't compile errors are false alarms** (3.1.3/S2, 3.2.3/S2, 3.4.3/S1, 5.3/R1, 5.5/R2, add-user, remove-plug-ins), and so are all 4 in v6: a vacuity-check bug, see *Gotchas*. With that fixed, about 64/75 would pass every check (v6 about 64 too), and every remaining failure is a compile error. The false alarms are also fed back into the repair loop, which probably explains part of the extra attempts and some regressions. Of the 11 that don't compile, 3 are logins that use `i.accounts` without declaring an `accounts` field in `Input` (3.1.3/S3, customer login, sales-person login), 3 use APIs that don't exist (`Function.sum`, `String.substring`, `List.nth`), 3 are type errors (`LE (Nat × Nat)`, `HAppend` with a proof-dependent `Option.get` plus `//` comments, `String.split ','` compared with a list), 2 reference fields that were never declared, and 1 is a `decide` failure on `String.all`. |
| Qwen 2.5 7B on ada, v8: vacuity fix, negative-check parsing, fixups, hints, prompt | 75 | Yes + L0.5 + negative check | **68/75 compile, 58/75 checked** (requirements 30/35, data 19/20, use cases 19/20); **L0.5: 56 pass, 11 flagged, 8 fail** (v7 re-reviewed with v8 checks: 53/11/11); **`rejects_bad_example`: 47 true, 1 false, 27 null** (v7: 75 null) | `runs/0000 - gamma j/qwen-v8/` | 2026-10-31, job 51236 (1080 Ti), 32 min of model time, 2.47 attempts per entry. 9 newly compile (3.1.3/S3, 3.3.3/S3, 3.5.3/S2, DD-item-name, DD-credit-card-expiry-date, DD-location, customer login, checkout, sales-person login: the accounts hint and `s.all` fixup worked), 5 regress (1.4/S4 recursion/termination, 3.1.3/S2 `Input.signedIn`, 5.3/R5 `a.failedAttempts` again, DD-shipping-date, register-customer `decide`). The only L0.5 fail that compiles is 3.5.3/S2, and it's a real one (`post` accepts an empty result list). **New problem: the negative check blocks correct data specs.** DD-item-name, DD-city and DD-order-no are right, but Qwen's "forbidden" example is valid (`"a"` for max 50 alpha, a 9-char alphanumeric for "9 characters"), so they end up unchecked. CI-2 and both logins are blocked by real catches or near-catches. 2 use cases fail `check_example_inputs` (different pre/post records). |
| Qwen 2.5 7B on ada, v9: search/filter/sort prompt section + template, parser keeps filter/sort/limit sentences and drops scope/overview prose, `Nat ≥ 0` rejected, per-mutant vacuity check | 74 | Yes + L0.5 + negative check | **67/74 compile, 59/74 checked**; **L0.5: 53 pass, 13 flagged, 8 fail** (v8: 56/11/8); **`rejects_bad_example`: 48 true, 26 null** | `runs/0000 - gamma j/qwen-v9/` (+ `comparison.md` vs v8) | 2026-11-02, 30.5 min of model time, 2.38 attempts per entry. Parser now drops `1.4/I3` (scope section). Mixed result: 6 improve (1.4/S4, 3.1.3/S2, 5.3/R5, register-customer now compile and pass), 11 regress, mostly ✅ → ⚠️ (`pre` is `True`, or no field types to vary) plus 4 new compile failures (3.3.3/S2, DD-credit-card-expiry-date, DD-location, update-product-attributes). Net is within run-to-run noise on gamma j; the v9 changes target search-style requirements (see video search below). |
| Qwen 2.5 7B on ada, **v8 code ×3** (baseline, seeds 42–44, `qwen-v8x3`) | 75 | Yes + L0.5 + negative check | mean (min–max): **67.3 (67–68) compile, 57.3 (56–58) checked**; **L0.5 53.3 (51–56) pass, 13.3 (11–16) flag, 8.3 (8–9) fail**; 2.58 attempts | `runs/0000 - gamma j/qwen-v8x3/rep1..3` | 2026-11-02. Run from a worktree at 6fedcde, llama-server restarted per seed. The spread between reps (5 L0.5 passes) is larger than most single-run deltas we reported before. |
| Qwen 2.5 7B, **v10 ×3** (seeds 42–44, prompt hash `a4ace6f72b38`) | 74 | Yes + L0.5 + negative check | **65 (65–65) compile, 62 (60–63) checked**; **L0.5 60 (57–63) / 4 (2–6) / 10 (9–11)**; 2.17 attempts | `runs/0000 - gamma j/qwen-v10/` (+ `comparison.md` vs v8x3) | 2026-11-02, ~27 min per rep. Compiles **worse** than v8 beyond the spread: `3.3.3/S2` failed 5/5 attempts in every rep on `i.items.sum (fun …)`, because fix 3 removed the `Function.sum`/`Function.map` usage advice and "Function expected" always blamed `Spec`. Fixed in v10.1. |
| Qwen 2.5 7B, **v10.1 ×3** (= v10 + function-misuse hints; L0 frozen here) | 74 | Yes + L0.5 + negative check | **67 (66–68) compile, 63.3 (59–67) checked**; **L0.5 61 (57–63) pass, 4.3 (3–5) flag, 8.7 (6–12) fail**; 2.16 attempts | `runs/0000 - gamma j/qwen-v10.1/` (`comparison.md` vs v8x3, `comparison-vs-v10.md`) | 2026-11-02. vs v8x3: compiles within noise, L0.5 pass +7.7 and flag −9 **better**, fail within noise, attempts −0.42 better. **Caveat:** most of the pass/flag change is fix 9 (no `pre is True` flag when the requirement states no precondition): 9–12 of v8's flags per rep were that flag. Scored the same way, pass rates are about equal (~64 vs 61). `3.3.3/S2` compiles 3/3. Always failing in every version: `5.5/R1`, `DD-shipping-date`; `DD-credit-card-expiry-date`, `DD-location`, `UC-customer-checkout-an-order` fail in 2/3. |
| Gemma (`gemma-4-31b-it`) | 4 (`1.4/I3`, `1.4/S2`, `1.4/S3`, `1.4/S4`) | Yes | 4/4 pass, mean 1.5 attempts, 2–5.5 min each | removed from the tree in dd67bca (still in 61ac8dc) | First run with the hardened prompt. Slow because of API retries. Compile ≠ correct: S2 ignores "initial", I3 doesn't say which orders get confirmed. |

## L0 results: `Requirements/2009 - video search.xml` (held-out SRS)

Second document, used to check that harness changes generalise beyond gamma j. Requirements only (no data dictionary or use cases).

| Run | Entries | Result | Where | Notes |
|-----|---------|--------|-------|-------|
| Qwen 2.5 7B, v8 code | 19 | **19/19 compile, 15/19 checked**; **L0.5: 7 pass, 9 flagged, 3 fail**; `rejects_bad_example` 10 true, 1 false, 8 null | `runs/2009 - video search/qwen-v8/` | 2026-11-02, 6.4 min. Compiles everywhere, but most specs were weak: 9 flagged, and three `1.3/S*` scope sentences were kept as requirements. This review motivated the v9 changes. |
| Qwen 2.5 7B, v9 code | 21 | **17/21 compile, 13/21 checked**; **L0.5: 9 pass, 4 flagged, 8 fail**; `rejects_bad_example` 9 true, 1 false, 11 null | `runs/2009 - video search/qwen-v9/` (+ `comparison.md` vs v8) | 2026-11-02, 10 min, 2.71 attempts per entry. Parser change: 3 scope sentences dropped, 5 filter/sort/limit requirements added (REQ-6, REQ-8, REQ-4#3, REQ-6#3, REQ-7#3), and all 5 fail L0.5 (2 don't compile, 3 have a `post` that doesn't constrain the output). On the 16 entries in both runs: checked 13 → 13, L0.5 pass 5 → 9, fail 2 → 3. So the prompt makes the specs stronger, but the new sort/filter/"display N" requirements are still not solved. |
| Qwen 2.5 7B, v10 (seed 42, single run) | 21 | **19/21 compile, 16/21 checked**; **L0.5 15 pass, 1 flag, 5 fail**; `rejects_bad_example` 10 true | `runs/2009 - video search/qwen-v10/rep1` (+ `comparison.md` vs v8) | 2026-11-02. **Not truly held out**: this SRS was looked at while writing v9. Single run, so no spread; differences to v8 (7/9/3) cannot be called real. |
| Qwen 2.5 7B, v10.1 (seed 42, single run) | 21 | **19/21 compile, 16/21 checked**; **L0.5 15 / 1 / 5** | `runs/2009 - video search/qwen-v10.1/rep1` (+ `comparison.md` vs v8) | 2026-11-02. Same totals as v10. Same caveats (seen during v9, single run). |

## L1: requirements graph → contracts (L1-v1, 2026-11-04)

Branch `l1-graph-contracts`. Reads the frozen L0 run `runs/0000 - gamma j/qwen-v10.1/rep1`;
L0, the parser and `Strings.lean` are unchanged. Qwen results: see *Results*
below. `benchmark/gammaj/Domain.lean` is REVIEWED (2026-11-06).

> **Changed 2026-11-12** (details in *chain-v3*, item 5, and *Graph v2*): the graph is version 2
> (entities also from the L0 specs, cycles broken instead of merged, new split rule), and a
> failing operation is degraded to its L0 conditions instead of blocking PO2. The text and
> numbers in this section describe L1-v1 as it was run; where they differ it is marked.

### Design: the graph decides the proof obligations

| Graph (`req_graph.py`) | Lean (`arch_lean.py`, written by the harness) |
|---|---|
| shared entity (Domain.lean structures + fields, data dictionary, glossary, actors, synonyms) | vocabulary for mapping fields; Domain.lean is in the locked context (namespace `Domain`) |
| operation = one compiling L0 spec | `namespace L0_<op>` (spec without its `example`); `req_<op>`/`res_<op>` constructors of `<G>Msg` |
| group = connected part of the operation–entity projection (+ use-case links) | one system: `<G>Msg`, locked `<G>SystemSpec : Contract Msg Msg` (one `match` case per L0 spec = their conjunction) |
| component (group, or recursive Louvain seed 42 above `CF_GRAPH_MAX_COMPONENT`=8 ops) | `<C>Contract : Contract Msg Msg`: owned requests use the model's `<C>_pre_<op>`/`<C>_post_<op>`, anything else passes through unchanged |
| L0 specs in a component | trace obligations `trace_pre/post_<C>_<op>`: `pre` assumes no more than the L0 `pre`; under it `post` implies the L0 `post` |
| topological order of the components | the chain `((c₁.seq c₂).seq c₃)…`; PO1 `po1_<A>_<B>` per consecutive pair; PO2 `po2_<G>` |
| cycles between components | listed in graph.json. v1: each strongly connected set merged into one component. v2 (default): components kept, chain order with the least backward dataflow, backward edges recorded as `feedback_edges` (`CF_GRAPH_CYCLES=merge` for v1) |
| requirement → L0 spec → component → contract | `arch.json` (operations, owner, obligations) for re-verification |

Every statement (trace, PO1, PO2, `system_sound_<G>`) is written by the harness; the model
only writes the two definitions per operation (and proof bodies if the harness's own proofs
fail). PO1/PO2 auto-proofs are generated per message constructor from the ownership map and
use only definitional steps (`cases`/`obtain`/`exact`) plus the trace lemmas, so they scale:
all 67 compiling gamma-j specs as one system check in ~12 s.

### Tools (`agents/arch_tools.py`, deterministic, no LLM)
`get_graph_summary`, `get_component`, `get_l0_spec`, `get_domain_types`, `lookup_name`,
`check_lean`, `check_contract` (compiles; satisfiable and `pre` true on the L0 example's own
literals; not vacuous = rejects some mutated output that the L0 `post` rejects; one Lean run),
`check_trace` (batched per component), `check_po1`, `check_po2`, `submit_architecture` (re-hashes
the locked context, discards earlier results and reruns everything, compiles the whole
`Arch.lean`). Model code may only add `def`s named `<C>_…`: no `sorry`/`admit`/`axiom`/
`native_decide`, no structures/instances/namespaces/options/macros, no reference to `L0_*.Spec`.
Operations the model never got right: in L1-v1 they got placeholder defs (`False`), were
reported, and made the verdict "rejected". Since 2026-11-12 they are degraded (their contract
is the L0 `pre`/`post`, written by the harness), as is any operation whose contract check or
trace fails; the verdict is then "accepted-degraded". `CF_ARCH_DEGRADE=0` gives the old behaviour.

### Modes
- **pipeline (default, `CF_ARCH_MODE`)**: per component in chain order, per operation:
  `generate_verified` with `check_contract` + `check_trace` as validator (only that operation's
  L0 spec as context, so cost does not grow with component size), then batched traces, model
  proof attempts if needed (`CF_ARCH_PROOF_RETRIES`=2), PO1, PO2, submit.
- **agent (`--arch-mode agent`)**: the model calls the tools (`llm.call_llm_tools`); needs
  llama-server with `--jinja` (`CF_QWEN_JINJA=1`). Budget `CF_ARCH_MAX_TOOL_CALLS`=40 (agent mode
  only). 3 malformed calls or the same call 3× → falls back to pipeline (`mode_used` records it).
- **no-graph (`--no-graph`)**: the model gets all L0 specs of the group (fields + requirement
  sentence) and returns a JSON decomposition; checked (every operation exactly once, ≥ 2
  components, CamelCase names), then the same pipeline and checks.

Prompt hash (`architect_agent.prompt_hash()`) and graph sha are in `arch.json` `meta`.

### Graph on gamma j (provisional; **graph version 1**, see *Graph v2* for the current numbers)
- With `benchmark/gammaj/Domain.lean` (committed `runs/0000 - gamma j/graph/`): **47.2% of fields
  mapped (116/246), 8 groups, 9 components, 6 cycles, 1 merged set**, 184 edges (178 dataflow,
  6 use-case). Main group 52 operations → `Account` (47, merged from the Account/Order/Product/
  Password cycle) → `Account2` (5: the sales-person product use cases + CI-1; named after
  account because their `name` field maps to `Account.name`, the only `name` in the domain).
  The other 7 groups are single data-dictionary fields (L1 skips groups with < 2 compiling
  specs). 15 operations isolated (performance specs, plug-in/patch use cases). Synonyms: 6.
  (Without Domain.lean: 36.2% mapped; with a scratch domain: 48.8%.)
- Real cycles exist (checkout writes an order, profile 3.1.3/S1 reads purchase history;
  checkout's precondition needs login). Unmapped fields are mostly session state (`signedIn`,
  `cookie`, `logged`) that no Domain type holds.

### Validation without a model
- Tests: `test_req_graph.py` (10: determinism across hash seeds, write→read edge, copies are
  reads, Bool results, unmapped fields, type/synonym mapping, Louvain size, cycle merge, order,
  precondition link `log in` ≠ `log out`), `test_arch.py` (12: every tool on a toy shop, a correct
  2-component architecture passes everything, rejects a changed Domain, a vacuous contract, an
  unprovable PO1, a single-component decomposition, placeholders). Whole suite: 98 tests pass.
- Dry run on the real rep1 specs with a fake model that copies each L0 `pre`/`post`: main group
  accepted, 98/98 obligations, 5.4 min; `Arch.lean` compiles standalone from the repo root
  (99 theorems). No-graph with a fake half/half split: accepted, 98/98. This tests the
  plumbing only.

### Results
Run 2026-11-06 on a GTX 1080 Ti (gnode004) with the local Qwen 2.5 7B Instruct Q4_K_M, pipeline mode,
seeds 42–44, group `AccountSys` (48 operations; the other 7 groups have < 2 compiling specs).
No smoke test and no agent-mode run were done. Full table: `runs/0000 - gamma j/qwen-L1-v1/comparison.md`.
Compare: `python evaluation/compare_runs.py "runs/0000 - gamma j/qwen-L1-v1-nograph" "runs/0000 - gamma j/qwen-L1-v1"`.

| | graph (B) | no-graph (A) |
|---|---|---|
| verdict | rejected ×3 | rejected ×1, "no valid decomposition" ×2 |
| `Arch.lean` compiles | 3/3 | 1/3 |
| components | 2 (Account, Account2) | 1.33 (0–4); rep3 chose 4 (Inventory, Accounts, ShoppingCart, Payment) |
| contracts satisfiable / non-vacuous | 100 % | 33 % (0–100) |
| trace proved | 99 % | 33 % (0–99) |
| PO1 proved | 100 % (1 pair) | 33 % (0–100) |
| PO2 proved | 0/3 | 0/3 |
| mean attempts per operation | 1.12 (1.10–1.15) | 0.36 (0–1.08) |
| failed attempts, `check` stage | 6.33 (5–7) | 0.67 (0–2) |
| minutes per run | 12.2 (11.4–13.2) | 4.6 (0.9–11.8) |

- **Graph mode:** 96/98 obligations proved every time. In each repeat exactly one `trace_post` fails and
  PO2 fails with it (it needs every trace first): `Account:3.5.3/S2` in rep1 and rep3, `Account:3.1.3/S1`
  in rep2. The error on `3.5.3/S2` is `Expected type must not contain free variables` (cause not yet investigated).
- **No-graph mode:** reps 1 and 2 returned a decomposition the harness rejected (60 s and 55 s, nothing
  proved). Rep3 was valid, 4 components, 98/100 proved, and failed the same obligation `Accounts:3.5.3/S2`, plus PO2.
- Graph mode is more reliable (compiles 3/3 vs 1/3, trace 99 % vs 33 %). The comparison tool calls this
  "within noise" because it is 3 repeats with a bimodal baseline, so treat it as indicative.
  The `check`-stage failures are higher with the graph (6.3 vs 0.7), but the no-graph runs mostly stopped early.
- PO2 is proved in no run, so by the plan Gemma should be run once (`--model gemma --run-name gemma-L1-v1`);
  this needs an API key in `.env`. Not done.
- Not done: agent mode (needs the tool-call check, which we skipped by choice).
- Open: why `3.5.3/S2` (and once `3.1.3/S1`) breaks the harness's own proof. Since 2026-11-12 the group is no longer
  blocked by it: replaying rep1 and rep2 with degrading gives `accepted-degraded`, 98/98, PO2 proved, that one operation degraded.

### Changes from the L1 task prompt (agreed with Akshith where marked)
1. (agreed) Contracts are over a harness-generated message type, not a shared `World` record:
   one `World → World` step cannot satisfy conflicting operations (login/logout), a start-to-end
   conjunction breaks down a chain, and lifting L0 types to `World` needs model-written maps that
   would shape `SystemSpec`. Domain types are the graph's vocabulary, not contract types.
2. (agreed) `SystemSpec` is harness-generated from the L0 specs (conjunction as a `match`).
3. (agreed) An output field only copied from the input (`o.f = i.f`) is a read.
4. (agreed) Cyclic component groups are merged, not stopped: stopping left gamma j nothing to run.
   **Revisited 2026-11-12 (not yet discussed with the team):** graph v2 breaks cycles by default and keeps
   the components, because merging put 47 of 52 operations into one component. `CF_GRAPH_CYCLES=merge` restores this.
5. A write needs entity-level evidence (field name/type names the entity); `Bool` results and
   attribute-only matches are results. Without this most edges were spurious (`emailSent`).
6. PO1 is proved for consecutive chain pairs (what soundness needs), not per graph edge; edges
   and their reasons stay in graph.json.
7. Contracts may not reference `L0_*.Spec` (else every contract is a trivial copy).
8. The harness tries its own proofs first; PO1/PO2 then follow mechanically from the traces,
   so PO1/PO2 % mostly measure trace %.
9. `--component` selects a group (a system); outputs are per group: `arch/<group>/`.

### Open problems
- A contract equal to the L0 conditions makes all obligations easy; nothing yet rewards a
  contract that says more than the requirement or relates operations to each other.
- 7 L0 specs do not compile (incl. checkout) and are excluded from L1.
- ~~Graph quality depends on Domain.lean and the synonyms file; session state has no entity.~~ Graph v2: entities
  also come from the L0 specs (helper structures, state fields); 73 % of gamma j fields map with neither file.
- ~~Louvain splits only groups > 8 operations, and merging cycles can undo most of the split.~~ Graph v2: split from
  4 operations when modularity ≥ 0.1; cycles broken, not merged. New open point: the state entities are not reviewed by hand.
- PO2 with degrading is only as strong as the non-degraded contracts; a run should report how many operations were degraded.

## L1/L2 end-to-end (2026-11-06, Qwen 2.5 7B, on v10.1-code specs)

| Run | Entries into L1 | L1 (PO1+PO2) | L2 (PO3) | Where | Notes |
|-----|-----------------|--------------|----------|-------|-------|
| e2e v1, gamma j | 61 (of 74; `checked` + accepted) | **0/61** | not run | `runs/0000 - gamma j/qwen-e2e/` | 5/5 attempts on every entry, ~56 min. L0 in this run: 67/74 compile, 64 checked, L0.5 63/3/8. |
| e2e v1, video search | 14 (of 21) | **0/14** | not run | `runs/2009 - video search/qwen-e2e/` | ~13 min. L0: 18/21 compile, 15 checked, L0.5 14/1/6. |
| e2e v2, video search | 14 | **9/14** (2.50 attempts) | **16/18 components**; **7/14 fully end to end** (L1 + every L2 + whole file re-checked in Lean) | `runs/2009 - video search/qwen-e2e-v2/` | 12 min, job 62032. Same specs as v1 (copied), new L1/L2 code. 3 of the 7 have a pass-through first component (`m.x = i.x` only: `REQ-3`, `REQ-3#2`, `REQ-4#2`), so they verify but don't really decompose. L1 fails: `REQ-1`, `REQ-4`, `REQ-7#2`, `REQ-4#3`, `REQ-5#3`. `REQ-1`: the second contract uses `i.query`, which it cannot see; `Mid` must carry every field the second component needs (prompt rule not added yet). |
| e2e v2, gamma j | 61 | **29/61** (3.18 attempts) | **48/58 components**; **19/61 fully end to end** (requirements 12/27, use cases 7/17, data constraints 0/17) | `runs/0000 - gamma j/qwen-e2e-v2/` (`summary.txt`; results split over `l1l2.json` + shard files `l1l2.<a>-<b>.json`, `evaluation/summarize_e2e.py` merges them) | 65 min of model time, run as 5 shards in parallel (jobs 62033, 62047–62050, 62064–62065) to finish before the mid-submission. Same specs as v1. **12 of the 19 have a pass-through first component**, so only ~7 are real decompositions. **All 17 data constraints fail L1**: a data constraint is one validity check (`valid ↔ conditions`), and the model moves the check into the second component's `pre` and sets `o.valid = true`, so PO2 is false. Fix: skip L1 (or allow one component) for single-step specs. Most L2 failures are 1/2 (one component implemented and proved, the other not). |

Why v1 failed (all 75):
1. Every reply re-declared `Input`/`Output`/`Spec` (the harness prepends the spec as context, so a repeat can never compile). Cause: the repair rules say "return the COMPLETE file" and the prompt showed the spec in a ```lean block. 263 "already declared" errors buried the real ones.
2. Component types didn't chain (`seq` needs `Contract Input Mid` then `Contract Mid Output`); only 33/61 did. Some used `Spec` as a component.
3. Prompt allowed 2–4 components, but PO2 / `system_sound` only cover two.
4. `intros` on `Compatible`/`Refines` without unfolding; `simp [Spec.pre]`.
5. **`discharge_po` could never close PO1/PO2**: it unfolds `Compatible`/`Refines`/`seq` but not the user's contracts, so `pre`/`post` stay opaque and it falls through to `decide` (fails to synthesize `Decidable`).
6. **L1 hit the L0 "write only a new example" path**: `split_example` treats the first `theorem` as the example, so a failing PO proof made the harness ask for an `example … unfold Spec; decide`.

v2 fixes (commits efaeef8..): `discharge_po [A, B, Spec]` unfolds named defs; `base.strip_redeclared` drops top-level declarations already in the context; example-only path only without context; L1 prompt: exactly two contracts, `Input → Mid → Output`, no copy-of-Spec/identity components, Lean-checked worked example; harness proof search (`agents/autoprove.py`) tries generic unfold + `simp_all`/`grind`/`omega` scripts on each PO when only the theorems fail; L0.5 report flags (not passes) a spec whose in-loop checks failed (`checked=False`, e.g. `3.4.3/S2`, `UC-administrator-manage-plug-in-options` in the e2e run).

Still open for L1/L2 as of v2 (known failures for the mid-submission report). **All five are addressed in code by
chain-v3 (2026-11-12, next section); none is measured with Qwen yet.**
- No semantic L1 validator: 15 of 26 end-to-end passes (both SRS) have a pass-through first component (`m.x = i.x` only). They verify but do not decompose. → chain-v3 item 1 (the v3 check finds more: 37 of the 38 accepted architectures are single-step or identity).
- Single-step specs (all data constraints) cannot be split into two components; L1 should skip them or allow one.
- `Mid` must carry every `Input` field the second component needs (video search `REQ-1` refers to `i.query` in the second contract). Not yet in the prompt. → chain-v3 item 3 (prompt rule + a check that names the field).
- L2 often proves only 1 of 2 components; L2 failures not yet analysed.
- Single runs (seed 42), so no spread yet; not wired into `main.py`. → chain-v3 items 8 and 9 (`main.py --until chain --repeat N`); the 3-seed runs are still to do.

## chain-v3 (2026-11-12): fixes to the per-spec L1/L2 path. **Qwen not rerun yet**

There is no Qwen model on the machine this was written on. Everything below was checked with
Lean, unit tests with a scripted model, and by replaying the 75 architectures and 76
implementations Qwen wrote in the v2 runs. New Qwen numbers need `sbatch runs/qwen-chain-v3.sbatch`.

### What the v2 replay showed (this changes how to read the v2 table)
- **Proofs were never the bottleneck.** With the model's theorems thrown away, the harness's own
  tactics prove PO1+PO2 for all 38 architectures v2 accepted, and PO3 for all 64 implementations
  v2 accepted. For the 28 rejected architectures whose definitions compile, PO1 or PO2 is false:
  the design is wrong (e.g. the second `pre` is `m.logged = true`, which the first contract never
  guarantees), not the proof.
- **v2's accepted architectures are mostly not decompositions.** Under the v3 static check the 38
  are: 21 single-step specs (v3 does not split them), 16 identity / copy-of-`Spec` splits, **1 real
  decomposition** (video search `REQ-5`). The earlier estimate "15 of 26 pass-through" only looked
  at the first component.
- **"One of two components proved" has two causes** (12 failed components): 6 implementations
  written backwards (`def ValidateContractImpl (m : Mid) : Input`), and contracts that cannot be
  implemented: the first `post` copies an `Input` field and then claims a fact about it
  (`m.value = i.value ∧ m.value ≤ 9999`), which no function can guarantee.

### Changes (by issue)
1. **Identity rule is checked, not only prompted** (`chain_checks.static_check`). Rejected before
   Lean: a first `post` made of copies (`m.f = i.f`) and restated preconditions, a second `post`
   made of copies (`o.f = m.f`), a contract equal to `Spec` up to variable names and spacing, a
   second contract that never reads what the first computes.
2. **Single-step specs are not split** (`chain_checks.single_step`): a data constraint, or a `post`
   with one top-level condition. Their architecture is `Spec` itself, PO2 is `Refines Spec Spec`,
   no model call, and L2 implements `SpecImpl`. `--split always|never` overrides.
   `--fallback-single` (off by default) keeps `Spec` whole when a split fails; those are
   `mode: single-fallback` and counted separately.
3. **Field visibility is checked before Lean.** A contract may only read fields of its own two
   records. An `Input` field read by the second contract gives: "Add `f : T` to `structure Mid`
   and `m.f = i.f` to the `post` of `<A>`" (also when it wrote `i.f`). The prompt states the rule.
4. **Strength record** per architecture (`l1.strength`): first does work, second does work, second
   uses the first's result, not a copy of `Spec`, second states an interface assumption (score of
   5; the first four are required). Plus a Lean check that the first contract is realizable: a
   fact about a copied field must follow from its `pre`.
5. **Graph L1 degrades per operation** (`ArchSession.degrade`, `CF_ARCH_DEGRADE=1` default): an
   operation with a failed contract check or unproved trace keeps its L0 conditions as its
   contract, so PO1/PO2 are proved for the group; verdict `accepted-degraded`, operations listed in
   `arch.json`. Replaying the stored Qwen L1 runs (model code from `arch.json`, same locked hash):
   rep1 (`rejected`, 96/98, PO2 blocked by `3.5.3/S2`) and rep2 (blocked by `3.1.3/S1`) both become
   **`accepted-degraded`, 98/98, PO2 proved, 1 of 48 operations degraded.** Why those two traces
   fail is still not investigated.
6. **Graph v2**: see *Graph v2* below.
7. **Failure classes** (`chain_failures.classify`), stored as `error_class` and counted by
   `summarize_e2e.py`; `root_cause` explains failed L2 components (backwards, not implementable).
8. **Repetitions**: `main.py --until chain --repeat N` → `runs/<doc>/<model>-chain-v3/rep<k>/`,
   seeds 42+k−1; `summarize_e2e.py` prints mean (min–max). **Not run** (needs the GPU node).
9. **One entry point, shared PO code**: stage `chain` in `main.py`; `po.py` (forbidden words,
   PO statements, one-Lean-run batches with errors attributed per theorem) is used by the chain
   path, `arch_lean.py` and `coding_agent.py`. The end-to-end file now ends with a harness-written
   `theorem system_ok : Spec.Satisfies (<B>Impl ∘ <A>Impl)` from `Contract.system_sound`.
10. **PO tactics** (`Tactics.lean`): `discharge_po2` takes the middle value of `seq` apart
    (`obtain ⟨y, hA, hB⟩`) before closing; `discharge_po1`; `discharge_po3` (splits an `if`).
    `autoprove.py` tries the matching one first. Correction to the issue as written: in PO2 the
    middle value is a hypothesis, so it has to be destructured, not supplied as a witness.

Design change behind 1, 3, 4, 10: **the model writes definitions only** (L1: `Mid` + two
contracts; L2: one function with the signature it is given). The harness writes every PO
statement, so a model can no longer prove a weaker theorem under the right name, and when a PO
fails it tries each conjunct on its own and names the one that does not follow (`PO1 fails: <A>.post
does not give \`m.inStock = true\``). `weakened()` is off for L1/L2: dropping an assumption from a
component `pre` is a legitimate repair.

### Expected effect and risk (unmeasured)
- Data constraints and one-condition specs (38 of 75 on the two SRSs) should now reach verified code
  through the single path: v2 got 0/17 data constraints end to end.
- The two-component rate may **fall**: v2's passes were identities, and whether Qwen 7B can write
  real decompositions with the new prompt and feedback is not known. If it cannot, most specs end
  as `single` / `single-fallback`, which is the honest result.

### Graph v2 (`req_graph.py`, issue 6)
| | v1 | v2 `--vocab full` | v2 `--vocab srs` (no Domain.lean, no synonyms file) |
|---|---|---|---|
| gamma j fields mapped | 47.2 % (36.2 % without Domain.lean) | 74.0 % | 73.2 % |
| groups / components | 8 / 9 | 9 / 18 | 16 / 23 |
| largest component | 47 operations | 15 | 9 |
| cycles | 6, one merged set | 5, none merged, 4 feedback edges | 2, 1 feedback edge |
| isolated operations | 15 | 10 | 10 |

Video search (it has no Domain.lean): 58.5 % mapped, 1 group, 3 components, no cycles.
- **Vocabulary from the specs themselves**: helper structures of the L0 specs are entities, and a
  field name that one spec reads and another writes is a state entity (`signedIn`, `logged`,
  `username`, …) even as a `Bool`. Domain.lean and the synonyms file are optional extras.
- **Split rule**: Louvain always above 8 operations, and from 4 operations when the communities
  are real (modularity ≥ 0.1); the settings are in `graph.json`.
- **Cycles are broken, not merged** (`CF_GRAPH_CYCLES=break`; `merge` = v1): components stay, the
  order with the least backward dataflow is used, backward edges are recorded. L1's proofs do not
  depend on the order, so nothing is lost; merging put 47 of 52 operations in one component.
- Plumbing check of graph L1 on the v2 gamma j graph (main group: 52 compiling operations, chain
  of 9 components) with a fake model that copies each L0 `pre`/`post`: 113/113 obligations (8 PO1,
  PO2, `system_sound`), `Arch.lean` compiles standalone in 14 s. The fake's copies failed the
  contract check for 34 operations, which were degraded, so this also ran degrading at scale; it
  says nothing about Qwen.
- State entities are structural, so generic names (`name`, `success`, `result`) can link specs that
  only share a word. Not reviewed by hand yet.

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
- **v8 fixes (2026-10-31, after reviewing qwen-v7; not yet run).** Whole test suite 41, passing (`test_harness_fixes.py` 27).
  - **Vacuity false alarm fixed:** `validate.one_line` collapses whitespace outside strings; `example_witness` and `_pre_input` return one-line literals, so pasted records parse (this also fixes `false_conjuncts`, which pasted them the same way). Re-reviewing the saved v7 specs in memory: L0.5 fail 18 → 11 (every remaining fail is a compile error), pass 42 → 53.
  - **Negative check:** `NEG_SYSTEM` now asks for `IN := {…}` / `OUT := {…}` lines only; `negative._bad_values` accepts that, `let IN := {…}` (what Qwen wrote) and the inline `Spec.post {…} {…}`. 7/8 of the logged qwen replies in `runs/negdiag/negdiag.log` parse now (0/8 before; the 8th is truncated in the log).
  - **Numeric data fields:** `value : Nat` specs no longer get "data tests skipped". Money fields have no bounds in the SRS, so nothing is tested; `max_ref` (quantity ≤ stock) is tested with value = limit (valid) and limit + 1 (invalid).
  - **Fixups:** `s.all`/`s.any` on a `String` field → `s.toList.all`/`.any` (fixes DD-item-name); end-of-line `// comment` → `-- comment` (not on lines with `{`, Lean's subtype `{ x // p }`). Applied to the 122 compiling specs of all runs that contain these patterns: none broke.
  - **Repair hints:** `i.accounts` missing from `Input` with `∃ a ∈ i.accounts, a.f …` → add `accounts : List Account` and a `structure Account` with the fields `post` reads (the 3 login failures); a field of the other record (`i.orderConfirmed` that is in `Output`) → write `o.…`; tuples without `LE` → helper structure; proof-dependent `Option.get` → `getD` / `= some v`. `MISSING_API`: `String.substring`, `String.slice`, `List.nth`, `List.nth?`, `List.nodup`, `Function.sum`, `Function.map`.
  - **Prompt:** those names in the "don't exist" list, plus no `String.split`, no tuples, no `Option.get`, `--` comments; new *Fields* section (`i.` = Input fields, `o.` = Output fields; `∃ a ∈ i.accounts` needs `accounts : List Account`).
  - Not code-fixable: `DD-shipping-date` compiles but rejects a valid date and accepts an invalid one (meaning error, flagged by the data tests); `pre := True` on performance requirements is correct.
- **v9 fixes (2026-11-02, after reviewing video search v8; run as `qwen-v9` on both SRSs).** Whole test suite 47, passing (`tests/test_v9_fixes.py`, template in `tests/search_template.lean`).
  - **Prompt (`spec_agent.py`):** new *Searching, listing, filtering, sorting, showing results* section (input items as `items : List Item`, results ⊆ items and complete, `Bool` options, `List.Pairwise` for order, `length ≤ N`, message ↔ empty) and a search template that compiles as is. No `x ≥ 0` on a `Nat`.
  - **Parser (`req_parser.py`):** `STATE_OP` also matches filter/exclude/sort/"arranged in"/"order by"/ascending/descending/alphabetical/"not be displayed"; `COUNT_RE` knows more nouns (results, entries, rows, pages, files, …); sentences in *scope*/*overview* sections are dropped unless they have a quantity or data relation.
  - **L0.5 (`validate.py`):** `i.x ≥ 0` / `0 ≤ o.x` is a housekeeping error; vacuity mutants are checked one at a time; a spec whose negative check found an accepted forbidden output fails.
- **v10 / v10.1 (2026-11-02). L0 is frozen at v10.1** (`HARNESS_VERSION` "v10.1", prompt hash `a4ace6f72b38`, branch `l0-v10`). Every fix is generic. Test suite: 5 files, all pass (`tests/test_v10_fixes.py` added).
  - **Fix 13, reproducible evaluation:** `CF_TEMPERATURE` 0.2, `CF_SEED` 42 (sent to Qwen), `main.py --repeat N` → `runs/<doc>/<model>-<version>/rep<k>/` with seed 42+k−1; `meta` in specs.json (version, model, temperature, seed, prompt hash, git commit). `evaluation/compare_runs.py <A> <B> [-o]`: mean (min–max) per metric; "better"/"worse" only when |Δmean| > spread. **Why:** single runs moved ±5 L0.5 passes on their own, so earlier "improvements" were noise.
  - **Fix 2, string helpers:** `framework/ContractForge/Strings.lean` (`allDigits`, `allAlnum`, `lenBetween`, `splitOn`, `digitVal`, `twoDigitNat`, `isMonth`, `isDay`, `isMMYY`, `isMMDDYYYY`, all over `List Char`, decidable). The prompt points to them instead of "do not split strings". Frozen.
  - **Fix 3, name suggestions:** unknown names/fields get the 3 closest real names by edit distance (Lean core, framework helpers, local names); `MISSING_API` table removed (the prompt's "These DO NOT exist" list stays). **Regression found and fixed in v10.1:** the table also held usage advice (`Function.sum`/`Function.map`), now generic hints: a list operation applied to a function → `(xs.map (fun x => …)).f`; "Function expected at X" names X and only mentions `Spec.pre`/`Spec.post` when X is `Spec`. Downside kept: `List.nth` now suggests `List.lt`/`List.nil`.
  - **Fix 4:** fixup adds `deriving DecidableEq, Repr` to structures without it (skips functions, `Float`, `Prop`, `Type`, self-reference). Qwen already derives: no measurable effect, safety net only.
  - **Fix 5:** undeclared field → names the field, the lines using it, "Add `x : <type>` to `structure S`". Never auto-inserted.
  - **Fix 6, truncation:** `CF_MAX_TOKENS` 2048, retry once with `CF_MAX_TOKENS_RETRY` 4096, then the attempt is marked truncated, never sent to Lean, and the loop restarts. Truncated = `finish_reason` length, or an unclosed fence only when no finish reason is given (an unclosed fence with "stop" is not truncation). Fired once per run on `DD-location` (the v9 runaway).
  - **Fix 7:** vacuity feedback quotes the requirement sentence for the field `post` never mentions.
  - **Fix 9:** `req_parser` marks `has_precondition`; L0.5 flags `pre True` only when the requirement has one. **This is most of v10's L0.5 pass gain** (a scoring change, not better specs).
  - **Fix 11:** data constraints get up to 3 forbidden inputs from the parser's rules (no LLM); pass only if all are rejected. Money fields and `DD-location` have no rules → `negative_verdict` unknown.
  - **Fix 12:** parser drops UI-only sentences (reason `ui: …`). Drops nothing new on either SRS today; only relabels.
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
- Use `discharge_po [<contracts>, Spec]` (names to unfold); plain `discharge_po` cannot see inside user contracts.
- Per obligation: `discharge_po1 [A, B]`, `discharge_po2 [A, B, Spec]`, `discharge_po3 [C, CImpl]`. In the chain path the harness writes these itself.

## Gotchas

- `simp only [defs]` can close a goal completely (a `True` precondition, `x ↔ x`); a following
  `intro` or `first | simp_all | …` then fails with "no goals". Every generated proof script starts
  its alternatives with `done`. Without it the PO diagnosis reported conjuncts that hold.
- `matches` is a Lean keyword: not usable as a field name (it was in a draft prompt example).
- Prompt examples are checked: `test_chain.py` and the replay ran both architect examples through
  `static_check` and Lean. Do the same when changing them.

- **L1 needs spaCy**: `python -m pip install spacy && python -m spacy download en_core_web_sm`
  (`runs/qwen-L1-v1.sbatch` installs it). graph.json records the versions; a different model can
  change lemmas and so the graph.
- spaCy lemmatises `id` to `i`: req_graph leaves words of ≤ 3 letters alone.
- `maxHeartbeats` is per declaration: a `simp` per `match` branch over a large inductive is
  quadratic and timed out PO1/PO2 at 67 operations. Generated PO proofs use `cases`/`exact` only.
- In generated proofs pass `i`/`o` explicitly: with `pre := fun _ => True` Lean cannot infer `_`.
- `obtain ⟨_, rfl, _⟩ := h` also succeeds on a plain equality; put `subst`/`cases` first.

- Run harness code from inside `harness/` (modules import each other as `from config import ...`).
- Run `lake build` in `framework/` once before the harness, or `import ContractForge` won't resolve (`main.py` builds it on first run).
- **`lake env lean <file>` only uses the Lake project in the current directory.** Run inside `runs/.../lean/` it finds none and fails with "unknown module prefix 'ContractForge'". Run from the repo root or `framework/`, or use `lake -d <repo root> env lean <file>`. In VS Code, open the repo root folder (the root `lakefile.lean` makes the infoview resolve the import) and restart the Lean server.
- **Lean marks a broken `def` with `sorry`.** "declaration uses `sorry`" next to a real error is a side effect, not the model writing `sorry`.
- **A real Gemini key was committed to `.env.example` in `dd2bdfe` and pushed to GitHub.** The working copy is now blanked, but the key is still in history: **revoke it in Google AI Studio** and put a new one in `.env`.
- `Requirements/parsed/0000 - gamma j.json` committed in 2573d72 was parsed from an older XML; re-parsing the current XML only changes `source.sha256`.
- Run logs (`runs/*.log`, e.g. `runs/qwen_server.log` written by `main.py`) are gitignored.
- **One negative example is a weak test.** The model picks it, and may pick an easy one the spec happens to reject; `rejects_bad_example: true` is evidence, not proof, that `post` is tight. It also only catches a `post` that accepts too much, not one that rejects correct outputs.
- **(Fixed in v8, kept for history.) L0.5 "`post` accepted every changed output" was a false alarm in every case in v6/v7 (found 2026-10-31).** `validate.check_vacuity` pastes the example's input record from `example_witness` into a new `example : ¬ (Spec.post {…} {…})`. When the model wrote that record across several lines, the pasted text doesn't parse in that position (`unexpected identifier; expected '}'`), the Lean run fails, and the failure is reported as a vacuous `post`. With the record on one line, all 11 flagged specs (v6: 4, v7: 7) reject the changed output. Until it is fixed, treat that L0.5 reason as unverified. The negative check (`agents/negative.py`) also depends on the example being in one exact form, so it probably has the same kind of bug.
- **Lean "checked" only means it compiles.** The `example` proves the spec is satisfiable, not that it matches the requirement. Vague requirements ("Confirm Orders") give specs that compile but say too little; review them by hand.
- **`gemma-4-31b-it` returned 500 INTERNAL on every call on 2026-10-30.** `gemma-4-26b-a4b-it` worked (`CF_GEMMA_MODEL=gemma-4-26b-a4b-it`), but at ~140 s per call.
- **ada setup (no sudo):**
  - Ollama's installer needs sudo, so don't use it; use llama.cpp.
  - `pip` isn't on PATH; use `python -m pip`.
  - Plain `conda install` fails until you accept Anaconda's ToS; use `--override-channels -c conda-forge`, or `python -m pip install --user cmake`.
  - CUDA comes from modules: `module load u22/cuda/12.4`.
- **Build llama.cpp with `-DGGML_NATIVE=OFF`.** A build on `ada-gw1` uses that CPU's instructions and crashes on the GPU nodes with exit code `-4` (illegal instruction). Also pass `-DCMAKE_CUDA_ARCHITECTURES="61;75;80;86;89"` (61 = GTX 1080 Ti, e.g. gnode005), because the login node has no GPU to detect.
- **Default `lake` on ada is Lean 4.35.0**; inside `framework/`, elan switches to 4.29.1 from `lean-toolchain`.

## Tests (2026-11-12)

`cd harness && python -m pytest`: **157 pass** (about 3 min with Lean). New: `tests/test_chain.py` (21: static
checks, PO diagnosis, single-step routing, coder, pipeline with a scripted model, repetition summary);
`test_arch.py` 15 (degrading); `test_req_graph.py` 15 (state entities, split rule, broken cycles).

## Next steps

00. **Run chain-v3 with Qwen** (`sbatch runs/qwen-chain-v3.sbatch`: both SRSs, 3 seeds, with and
    without `--fallback-single`) and put the summary here. Rebuild the gamma j graph
    (`--until graph`) and rerun graph L1 ×3 to measure degrading and graph v2 with the model.
    Then: review the state entities by hand; decide whether `--fallback-single` should be the
    default; Lean implementation → Python (the last step of the intended pipeline, not started).

0. **Mid-submission 2026-11-06 23:59** (4-page progress report + repo link). After it: L1 semantic validator (reject identity / copy-of-`Spec` components), wire L1/L2 into `main.py`, ×3 reps of the e2e runs, then L2 results.

0. **L1:** Qwen runs done (see *L1 → Results*; PO2 proved in no run). Left: run Gemma once (`--model gemma --run-name gemma-L1-v1`,
   needs `.env`), look into the one failing `trace_post` (`3.5.3/S2`, `3.1.3/S1`), optionally an agent-mode run. Nothing is committed yet.


1. **L0 is frozen at v10.1.** Open L0 issues, for after the freeze or a v11: the run-to-run compile failures (`5.5/R1` Decidable on a structure, `DD-shipping-date` and `DD-credit-card-expiry-date` date formats, `DD-location`, `UC-customer-checkout-an-order` writing `Spec.post {…}` with one record that mixes input and output fields — the `_field_of_other` hint misreads that as `i.x` vs `o.x`). Get a truly held-out SRS (video search was seen during v9). Compare runs only with `evaluation/compare_runs.py` over ≥3 reps.
1. (old) v9 is done on both SRSs (`qwen-v9`; compare with `scripts/compare_runs.py <before> <after>`, reports in each `qwen-v9/comparison.md`). Next: the sort / filter / "display N results" requirements of video search (all 5 new ones fail L0.5: look at their Lean files); the gamma j ✅ → ⚠️ regressions (`pre := True`, "no field types to vary"); the 4 new compile failures. Still open from v8: check the model's forbidden example against the parser's rules before trusting it (DD-item-name, DD-city, DD-order-no). Commit the v8/v9 runs and the v9 code.
2. Commit `runs/0000 - gamma j/qwen/` (prompt v2) and `qwen-baseline/` (v1). Next for L0: add the APIs Qwen still invents (`List.nodup`, `String.last`, `String.toInt`, `Char.isAlphabetic`) to the "don't exist" list and repair hints; look at the 7 entries that regressed.
3. Review the checked specs for meaning, not just compilation (see *Gotchas*).
4. Run Gemma (and DeepSeek/Groq if keys are available) on all 75 entries with `--resume` to get comparable L0 pass rates.
5. ~~Wire L1 (architect) and L2 (coding) stages into `main.py`~~ done: graph path `--until arch`/`code` (2026-11-06), chain path `--until chain` (2026-11-12).
6. ~~Add `requirements.txt`~~ done 2026-11-12.
7. First benchmark system: `benchmark/bank_ledger/`.
8. `evaluation/metrics.py` with the `RunResult` dataclass from the kickoff guide.
