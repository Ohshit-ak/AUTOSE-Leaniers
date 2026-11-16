# Tests

Run from `harness/`:

```bash
python -m pytest                         # everything (needs lake; ~15 min)
python -m pytest -m "not lean"           # text-only suites, about 2 min
python -m pytest -m "not slow"           # skips the Lean replays of recorded runs
HYPOTHESIS_PROFILE=thorough python -m pytest tests/test_pbt_text.py tests/test_pbt_pipeline.py   # 1000 examples, random
```

## Suites

| File | Kind | What it checks |
|---|---|---|
| `test_pbt_text.py` | property-based | Laws of the text functions on generated input: round trips (`contract_text`/`parse_contracts`, `_literal`/`literal_fields`, Lean output/`parse_errors`), idempotence (`fixups`, `clean`, `slug`, `strip_*`), invariants (`conjuncts`, `canon`, `skeleton.build`, `format_feedback`), agreement with reference implementations written in the test (data test values, contradiction check, edit distance) and between the three structure parsers. |
| `test_pbt_pipeline.py` | property-based | `req_parser.parse_bytes` on generated SRS documents (every statement kept or dropped once, decision depends only on text and section kind, ids, categories); accounting identities of `summarize_e2e.metrics` / `failures` and `compare_runs`; graph ordering (`order_cycle` optimal, `chain_order`, `dataflow_edges`, `split_group` partitions). |
| `test_metamorphic.py` | metamorphic | Relations between two runs of the same function: whitespace / namespace / re-serialisation of an SRS, alpha-renaming and conjunct order of real L0 specs, renaming / definition order / comments on real L1 architectures, locked-context offset of repair feedback, repetition order / shards / self-comparison in the evaluation scripts. Source inputs are the recorded outputs under `runs/`. |
| `test_contract_outputs.py` | contract | The files the stages exchange (`schemas.py`): parsed JSON, `specs.json`, `review.json`, `chain_meta.json`, `l1l2.json`, `l1l2/*.lean`, `graph.json`. Schema, cross-field invariants, and replay of every deterministic part (parse, failure class, end-to-end theorem, Lean file, field provenance). Also recomputes `summary.md`, `results.md` and the README headline from the data. |
| `test_lean_contracts.py` | contract + property + metamorphic, with Lean | `check_lean` interface and error format; algebraic laws of the framework proved in Lean (refinement is a preorder, `seq` associative up to refinement, PO1 and PO2 are necessary); string helpers against a Python reference; skeletons correct by construction and mutants rejected; error attribution of batched theorems; replay of recorded verdicts. |

Shared: `strategies.py` (Hypothesis generators), `corpus.py` (recorded outputs), `schemas.py`, `conftest.py` (profiles, markers).

## Reading a result

- `xfail` = a defect the suite found and documents. The reason starts with `FINDING:` and gives the smallest
  counterexample. The marks are strict: when the defect is fixed the test reports XPASS as a failure, and the mark
  must be removed.
- `KNOWN_*` constants in `test_contract_outputs.py` list deviations in the recorded data. They are compared
  exactly, so a new deviation fails and so does a silent fix.
