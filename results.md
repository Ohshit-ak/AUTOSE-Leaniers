# Results: chain-v3 (L1 + L2 per spec), Qwen 2.5 7B

Run on 2026-11-12/13. Slurm job 74718, `runs/qwen-chain-v3.sbatch`, GTX 1080 Ti (gnode006), 2 h 36 min total.
Commit `372bda4` (`git_dirty: false` in every `chain_meta.json`). Model `qwen2.5-7b-instruct` (Q4_K_M, llama.cpp),
temperature 0.2 (restart 0.7). Three repetitions per setting, seeds 42, 43 and 44. L0 is frozen at `qwen-v10.1/rep1` for both SRSs.

Numbers are **mean (min–max) over the 3 repetitions**. v2 (`qwen-e2e-v2`) is a single run, so it has no spread.
The full summaries, including per-spec lists, are in `runs/<doc>/qwen-chain-v3/summary.md`.

Two settings:
- **strict** (`qwen-chain-v3`): a spec that needs a split must get a real two-component architecture, or it fails.
- **fallback** (`qwen-chain-v3-fallback`, `--fallback-single`): when the split fails, `Spec` is implemented as one component (mode `single-fallback`).

## Headline: fully verified end to end (`system_ok` checked by Lean)

| SRS | specs | v2 (1 run) | v3 strict | v3 fallback |
|-----|------:|-----------:|----------:|------------:|
| 0000 - gamma j      | 61 | 19 | **38.67** (37–40) | **50.67** (50–51) |
| 2009 - video search | 15 (v2: 14) | 7 | **6.67** (6–7) | **9.33** (7–11) |

The v2 and v3 counts measure different things. Under the v3 static check, v2's 38 accepted architectures were
21 single-step specs, 16 identity splits and 1 real decomposition. v3 no longer counts identity splits as decompositions.
Its "end to end" is made of single-step specs proved against `Spec` directly, plus real two-component chains.

## Gamma j (61 specs)

| | strict | fallback |
|---|---|---|
| routed single-step (no split, no model call in L1) | 38 | 38 |
| …of which end to end | 34.67 (34–35) | 46.00 (46–46) incl. fallback |
| specs that needed a split | 23 | 23 |
| L1 accepted, two components | 6.33 (6–7) | 7.00 (6–8) |
| L1 single-fallback | — | 16.00 (15–17) |
| end to end, real chain | 4.00 (3–5) | 4.67 (4–5) |
| L2 components implemented / total | 45.00 / 50.67 | 57.67 / 68.00 |
| strength of accepted chains (of 5) | 4.94 | 5.00 |
| L1 attempts per split spec | 4.38 | 4.28 |
| minutes per repetition | 16.5 | 20.5 |

By spec kind (end to end / specs):

| kind | v2 | v3 strict | v3 fallback |
|------|---:|----------:|------------:|
| data constraint | 0 / 17 | **17.00 / 17** | 17.00 / 17 |
| requirement | 12 / 27 | 15.33 / 27 | 20.67 / 27 |
| use case | 7 / 17 | 6.33 / 17 | 13.00 / 17 |

**L1 failures, strict** (mean per repetition): po1 4.67, visibility 3.67, identity 3.33, po2 1.67, unknown-name 1.33,
type-error 1.00, unknown-field 0.67, syntax 0.33. The harness now rejects most failed splits for semantic reasons
(PO1, visibility, identity). In v2 most failures were Lean type errors (20 of 32).

**L2 failures, strict:** po3 3.00, unknown-field 2.00, type-error 0.67. In every case where only one of the two
components was implemented, the one that failed was the **second** component. v2's "implementation written backwards
(`Mid → Input`)" failures of the first component no longer occur. Two specs fail the same way in every repetition,
with `unknown-field` on the second component: `3.2.3/S1` and `UC-customer-add-item-to-cart`.

Not end to end in any strict repetition (21): 1.4/S3, 3.1.3/S1–S3, 3.2.3/S1–S2, 3.3.3/S1–S2, 5.3/R4, 5.3/R5, SI-1.2,
and 10 use cases (administrator add/change/remove user, install patch, remove plug-ins; customer add-to-cart,
edit details, login; sales person add product, update product attributes). Fallback leaves 10 of these.

## Video search (15 specs)

| | strict | fallback |
|---|---|---|
| routed single-step | 5 | 5 |
| …of which end to end | 5.00 (5–5) | 7.33 (6–8) incl. fallback |
| specs that needed a split | 10 | 10 |
| L1 accepted, two components | 3.67 (3–4) | 4.33 (3–6) |
| L1 single-fallback | — | 5.67 (4–7) |
| end to end, real chain | 1.67 (1–2) | 2.00 (1–3) |
| L2 components implemented / total | 9.33 / 12.33 | 13.33 / 19.33 |
| strength of accepted chains (of 5) | 4.19 | 4.11 |
| minutes per repetition | 6.8 | 8.1 |

**L1 failures, strict:** po2 4.00, identity 1.33, po1 0.67, visibility 0.33. On this SRS **PO2 is the main blocker**:
the two contracts compose, but together they do not refine `Spec`.
**L2 failures:** mostly po3 (2.33). Every one-of-two failure is again in the second component (`ShowResults…`/`FormatResults…`).
Not end to end in any strict repetition: REQ-1, REQ-2, REQ-3, REQ-3#2, REQ-4, REQ-4#2, REQ-4#3, REQ-6.
With fallback: REQ-1, REQ-4, REQ-6.

The 15 vs 14 specs come from the L0 input. v2 used its own L0 run, while v3 reads `qwen-v10.1/rep1`, which has one more accepted spec (`REQ-6`).

## Takeaways

1. **Single-step routing gives the largest gain.** All 17 data constraints now verify end to end (v2: 0), and almost
   every single-step spec verifies (34.67/38 on gamma j, 5/5 on video search).
2. **Real decomposition is still rare.** Of the specs that need a split, Qwen 7B produces an accepted non-trivial architecture for
   about 28% on gamma j (6.33/23) and 37% on video search (3.67/10). Of those, 63% (gamma j) and 45% (video search) then verify end to end.
   The accepted chains are strong (strength 4.9/5 on gamma j), so the identity/copy splits that inflated v2 are filtered out.
3. **What blocks splits:** on gamma j, PO1 and visibility (the second contract reads `Input` fields not passed through `Mid`).
   On video search, PO2.
4. **L2 weak spot:** the second component (consumer of `Mid`). The causes are `unknown-field` (references to fields `Mid`
   does not have) and PO3 failures on the output `post`.
5. **Fallback** lifts the end-to-end count to 83% (gamma j) and 62% (video search) of accepted L0 specs. These count
   as verified code, not as decompositions, and are reported separately.

## Checks I did

- `python -m pytest` in `harness/`: 157 passed, 0 skipped (after installing `requirements.txt`).
- No `sorry` in any generated `l1l2/*.lean` file.
- Re-checked two chain end-to-end files independently with `lake env lean`, and both compile:
  `runs/0000 - gamma j/qwen-chain-v3/rep1/l1l2/3.4.3_S3.lean` and `runs/2009 - video search/qwen-chain-v3/rep1/l1l2/REQ-5.lean`.
  Each has `system_ok` proved via `Contract.system_sound po1 po2 …`.

## Issues hit while running (fixed)

1. **Server-start race in the sbatch** (job 74716 failed): the wait loop used `curl -s`, which counts llama-server's
   503 during model loading as success. `main.py` then found the server down, started a second one on port 8082, and the bind failed.
   Fixed by changing it to `curl -sf` in `runs/qwen-chain-v3.sbatch` (not committed yet).
2. **Missing Python deps** (job 74717 failed): `networkx` was not installed in the conda env. I installed `requirements.txt` and
   the spaCy model `en_core_web_sm`. The 15 previously skipped tests were skipped for this reason.
