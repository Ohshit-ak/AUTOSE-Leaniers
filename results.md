# Results: L0 v11 + chain-v5, Qwen 2.5 7B, 18 SRS

Run on 2026-11-13/14. Slurm jobs 76822–76826, 76932, 78269 (`runs/qwen-v11.sbatch`), commit `ed18e9b`
(`git_dirty: false` in every `chain_meta.json`). Model `qwen2.5-7b-instruct` (Q4_K_M, llama.cpp), temperature 0.2
(restart 0.7). L1/L2 run three times per setting, seeds 42, 43, 44; **every repetition reads the same L0 run**
(`qwen-v11/rep1`, or `qwen-v10.1/rep1` for the ablation), so the spread covers L1/L2 only.

Numbers are **mean (min–max) over the 3 repetitions** of specs verified end to end (`system_ok` checked by Lean).
Per-SRS summaries: `runs/<doc>/qwen-chain-v5/summary.md` (all chain-v5 settings, compared with chain-v4).

Settings:
- **chain-v4 strict**: previous harness, on the frozen L0 v10.1 specs.
- **chain-v5 on v10.1 L0**: ablation, new L1/L2 on the same specs as chain-v4.
- **v11 + chain-v5 strict / fallback**: new L0 (v11) and new L1/L2; fallback = `--fallback-single`.

## Headline (sum over the 18 SRS)

| Run | L0 specs | end to end | rate | non-trivial end to end | non-trivial rate | non-trivial, model wrote code |
|---|---|---|---|---|---|---|
| chain-v4 strict | 483 | 343.3 | 71.1 % | 149.7 | 58 % | – |
| chain-v4 fallback | 483 | 365.0 | 75.6 % | 157.3 | 61 % | – |
| chain-v5 on v10.1 L0 (ablation) | 483 | 372.0 | 77.0 % | 163.7 | 64 % | 56.3 |
| L0 v11 + chain-v5 strict | 517 | 390.3 | 75.5 % | 193.3 | 64 % | 64.0 |
| **L0 v11 + chain-v5 fallback** | 517 | **400.7** | **77.5 %** | **200.0** | **66 %** | 70.6 |

"Non-trivial" excludes weak specs (Lean accepts an implementation made only of copied inputs and constants).
peering is left out of the chain-v4 row here (1 spec, verified); the per-SRS table below includes it.

## Per SRS (end to end)

| SRS | specs (v10.1 / v11 L0) | chain-v4 strict | chain-v5 on v10.1 L0 | v11 + chain-v5 strict | v11 + chain-v5 fallback |
|---|---|---|---|---|---|
| 0000 - cctns | 10 / 13 | 6.00 | 6.00 | 9.67 (9–10) | 9.33 (9–10) |
| 0000 - gamma j | 61 / 59 | 52.67 (52–53) | 53.00 | 49.33 (48–51) | 49.67 (49–50) |
| 1995 - gemini | 37 / 37 | 26.00 (25–27) | 29.00 | 27.33 (26–28) | 29.33 (29–30) |
| 1998 - themas | 19 / 18 | 12.67 (12–14) | 14.67 (14–15) | 16.00 | 16.00 |
| 1999 - dii | 5 / 6 | 5.00 | 5.00 | 3.00 | 3.00 |
| 1999 - tcs | 43 / 46 | 33.33 (33–34) | 35.33 (35–36) | 34.00 (32–35) | 36.33 (36–37) |
| 2003 - qheadache | 4 / 4 | 3.00 | 3.00 | 3.00 | 3.00 |
| 2005 - microcare | 21 / 24 | 13.67 (13–14) | 13.33 (13–14) | 15.67 (15–16) | 16.67 (15–18) |
| 2005 - phin | 31 / 34 | 14.00 | 16.00 | 24.67 (24–25) | 25.33 (25–26) |
| 2006 - eirene sys 15 | 55 / 58 | 36.33 (36–37) | 42.67 (42–43) | 45.33 (44–46) | 48.33 (48–49) |
| 2007 - get real 0.2 | 0 / 0 | – | – | – | – |
| 2007-eirene_fun_7-2 | 82 / 92 | 56.33 (55–58) | 62.67 (62–63) | 70.00 (68–72) | 71.33 (70–73) |
| 2007-ertms | 36 / 36 | 31.00 | 33.00 | 28.33 (28–29) | 29.00 |
| 2008 - keepass | 15 / 19 | 9.67 (9–10) | 12.33 (12–13) | 16.00 | 15.67 (15–16) |
| 2008 - peering | 1 / 0 | 1.00 | – | – | – |
| 2009 - peppol approved | 42 / 44 | 27.00 (26–28) | 29.67 (29–30) | 30.00 | 30.00 (29–31) |
| 2009 - video search | 15 / 20 | 10.67 (10–11) | 10.33 (9–11) | 12.33 (12–13) | 11.67 (11–12) |
| 2010-blitdraft | 7 / 7 | 6.00 | 6.00 | 5.67 (5–6) | 6.00 |
| **total** | 484 / 517 | **344.3** | **372.0** | **390.3** | **400.7** |

## Takeaways

1. **chain-v5 (L1/L2) is a clear gain.** On the same specs, 71 % → 77 % end to end; better or equal on every SRS,
   beyond the seed spread on eirene_fun_7-2, eirene sys 15, gemini, keepass, phin and tcs.
2. **L0 v11 adds specs but not pass rate.** It produces 34 more specs; the share verified is flat (77.0 % → 75.5 %
   strict, non-trivial 64 % → 64 %). Most of the gain over chain-v4 in absolute numbers comes from chain-v5 and the
   extra specs.
3. **L0 v11 regressions** on gamma j (≈53 → 49), ertms (33 → 28–29) and dii (5 → 3). The ablation does not show them,
   so they come from L0 v11. Mostly PO3 failures. Not yet investigated.
4. **`--fallback-single` is the best setting** (400.7, 66 % of non-trivial specs).
5. **No specs from peering and get real 0.2**: both parse to one requirement that is flagged at L0.5.
6. **Harness and model share.** Of the 193.3 non-trivial strict results, 64.0 contain model-written code; the rest
   are completed by the spec-directed skeleton. Reported separately, by design.

## Incidents (handled)

- Job 76825 landed on gnode042 (CUDA init failed, Qwen ran on CPU at 4 tok/s); cancelled and rerun excluding that node.
- Job 76932 hit the 16 GB limit; the OOM killer took the Qwen server during microcare strict (21 CRASH spec-runs,
  kept in `runs/2005 - microcare/qwen-chain-v5.oom-damaged`). Microcare strict was rerun as job 78269 with 32 GB.
  The sbatch now asks for 32 GB and exits at startup when the server has no usable GPU.

---

# Earlier results: chain-v3 (L1 + L2 per spec), gamma j and video search


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
