# ContractForge: how L0 works (English requirement → checked Lean spec)

Code: `harness/` (run from there with `python main.py`). Lean side: `framework/ContractForge/Contract.lean`.
Numbers in the last section are from the `qwen-v8` run on `0000 - gamma j.xml` (75 entries).

## 1. Whole pipeline

```mermaid
flowchart TD
    XML["SRS document<br/>Requirements/*.xml"]
    subgraph PARSE["Stage parse · req_parser.py (deterministic, no LLM)"]
        P1["Parse XML → requirements,<br/>data dictionary, use cases"]
        P2["Drop statements that can't be a Lean proposition<br/>(vague words, UI steps, tech choices) → 'dropped' + rule"]
        P1 --> P2
    end
    JSON["Requirements/parsed/&lt;doc&gt;.json"]
    subgraph SPEC["Stage spec · L0 · main.py stage_spec"]
        S1["spec_prompts(): one prompt per entry<br/>(requirement / data_constraint / use_case)"]
        S2["run_spec() → generate_verified()<br/>LLM + Lean repair loop (diagram 2)"]
        S3["Save after every entry:<br/>specs.json + lean/&lt;id&gt;.lean"]
        S1 --> S2 --> S3
    end
    subgraph CHECK["Stage check · L0.5 · validate.py review_run"]
        C1["Rule checks on each final spec (diagram 3)"]
        C2["pass / flag / fail per entry"]
        C3["l05_report.md + review.json<br/>(accept / review / redo)"]
        C1 --> C2 --> C3
    end
    DEC{"Any fail?<br/>--on-l0-fail"}
    STOP["stop: a person edits review.json"]
    REDO["redo: rerun L0 once<br/>for the failed ids"]
    EXCL["exclude: mark failed<br/>entries 'exclude'"]
    L1["L1 architect / L2 coding<br/>(not wired in yet)"]

    XML --> PARSE --> JSON --> SPEC --> CHECK --> DEC
    DEC -- no --> L1
    DEC -- stop --> STOP
    DEC -- redo --> REDO --> SPEC
    DEC -- exclude --> EXCL --> L1
```

## 2. The L0 loop for one entry (`agents/base.py generate_verified`)

At most `MAX_RETRIES = 5` attempts. Each spec is Lean code: `structure Input`, `structure Output`,
`def Spec : Contract Input Output` with `pre` / `post`, and an `example` proving
`Spec.pre i ∧ Spec.post i o` by `decide`.

```mermaid
flowchart TD
    START(["Prompt for one entry<br/>+ SYSTEM_PROMPT_SPEC + REPAIR_RULES"]) --> LLM["LLM (Qwen) writes Lean<br/>extract_lean: last lean code block that defines Spec"]
    LLM --> FIX["fixups.py: mechanical rewrites<br/>(// → --, s.all → s.toList.all, keyword field names …)"]
    FIX --> WEAK{"weakened()?<br/>pre/post made weaker<br/>than the first attempt"}
    WEAK -- yes --> FBW["Feedback: 'restore the meaning'"]
    WEAK -- no --> LEAN["lean_runner.check_lean<br/>lake env lean (framework imported)<br/>sorry = failure"]
    LEAN -- compiles --> HARD["hard_checks (validate.py)<br/>+ negative check (diagram 3)"]
    HARD -- no problems --> OK(["✔ checked: return spec"])
    HARD -- problems --> FBC["Feedback: list of L0.5 problems"]
    LEAN -- errors --> STAGE["repair.py: sort errors by stage<br/>syntax → names → types → proof<br/>+ targeted hints (missing API, wrong struct field,<br/>missing accounts list, tuples, Option.get …)"]
    STAGE --> EX{"Only the example<br/>is wrong?"}
    EX -- no --> SAME
    EX -- yes --> SRCH{"Definitions already<br/>searched?"}
    SRCH -- no --> WIT{"find_witness:<br/>search values that<br/>satisfy pre ∧ post"}
    WIT -- found --> LEAN
    WIT -- none --> CONTRA["Tell model: pre/post look contradictory"]
    SRCH -- yes --> VT{"Example-only<br/>retries < 2?"}
    VT -- yes --> LOCK["Lock definitions,<br/>ask for a new example only"]
    LOCK --> LLM
    VT -- no --> SAME
    CONTRA --> SAME
    FBW --> SAME
    FBC --> SAME
    SAME{"Same error<br/>as last time?"}
    SAME -- yes --> RESTART["Start over from the prompt<br/>temperature 0.7"]
    SAME -- no --> REPAIR["Send code + feedback in chat history<br/>'Return the full corrected code'"]
    RESTART --> LLM
    REPAIR --> LLM
    LEAN -. "attempt 5 failed" .-> BEST(["✘ return best attempt:<br/>compiles-but-failed-checks &gt; Lean error &gt; weakened"])
```

## 3. What "checked" means: the checks on a compiling spec

```mermaid
flowchart LR
    CODE["Spec compiles"] --> A["check_contradictions<br/>always-false equations"]
    A --> B["check_example_inputs<br/>pre and post get the same input"]
    B --> C["check_housekeeping<br/>one def Spec, no sorry/axiom/native_decide,<br/>has an example"]
    C --> D["check_parser_facts<br/>runtime checks from the parser<br/>appear in the spec"]
    D --> E["check_vacuity<br/>change each output field of the example:<br/>post must reject at least one change"]
    E --> F["Negative check (agents/negative.py)<br/>LLM proposes IN + a FORBIDDEN OUT"]
    F --> G{"Lean on the forbidden example"}
    G -- "pre IN ∧ ¬ post IN OUT proved" --> PASS(["rejects_bad_example = true ✔"])
    G -- "post IN OUT holds" --> BAD(["spec too weak → feedback to L0 loop"])
    G -- "example unusable<br/>(pre false, parse error)" --> UNK(["unknown: does not block"])
```

After L0, `review()` reruns housekeeping, parser facts and vacuity on the final spec, and adds
**data tests** for data-dictionary fields (length / charset / format / numeric bounds from the parser,
tested on valid and invalid sample strings) and the **`pre` is `True`** flag:

```mermaid
flowchart LR
    R["Final spec"] --> CMP{"Compiles?"}
    CMP -- no --> FAIL["❌ fail"]
    CMP -- yes --> HARD2{"housekeeping / parser facts /<br/>vacuity problems?"}
    HARD2 -- yes --> FAIL
    HARD2 -- no --> FL{"Flags?<br/>pre = True, data test mismatch,<br/>tests skipped"}
    FL -- yes --> FLAG["⚠️ flag: a person reviews"]
    FL -- no --> PASS2["✅ pass"]
```

## 4. Results: qwen-v7 → qwen-v8

| | v7 | v8 |
|---|---|---|
| Specs that compile | 64/75 | **68/75** |
| Checked (passed every check in the loop) | 57 | **58** |
| L0.5 pass / flag / fail | 42 / 15 / 18 | **56 / 11 / 8** |
| Negative check: rejects / accepts forbidden / no verdict | 0 / 0 / 75 | **47 / 1 / 27** |
| Attempts per entry | 2.60 | 2.47 |

Remaining v8 failures: 7 don't compile (missing Lean APIs, Dijkstra with tuples, broken syntax),
1 vacuous `post` (3.5.3/S2), 3 correct data specs blocked by a wrong "forbidden" example from the
model, 3 specs that get the meaning wrong (CI-2, 5.5/R5, two logins), 2 examples with different inputs.
