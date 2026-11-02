# `qwen-v8x3` (3 reps) → `qwen-v10.1` (3 reps)

Document: `0000 - gamma j.xml`

- A: no metadata (run before v10)
- B: harness_version `v10.1`, model_id `qwen2.5-7b-instruct`, temperature `0.2`, prompt_hash `a4ace6f72b38`, git_commit `b01f013`, seeds [42, 43, 44]

Mean (min–max) over repetitions. A change is real only if the means differ by more than the spread (max − min) of either run.

| metric | A: qwen-v8x3 | B: qwen-v10.1 | Δ mean | verdict |
|---|---|---|---|---|
| entries | 75 (75–75) | 74 (74–74) | -1.00 | **worse** |
| compiles | 67.33 (67–68) | 67 (66–68) | -0.33 | within noise |
| checked (L0 OK) | 57.33 (56–58) | 63.33 (59–67) | +6.00 | within noise |
| L0.5 pass | 53.33 (51–56) | 61 (57–63) | +7.67 | **better** |
| L0.5 flag | 13.33 (11–16) | 4.33 (3–5) | -9.00 | **better** |
| L0.5 fail | 8.33 (8–9) | 8.67 (6–12) | +0.33 | within noise |
| negative: rejects | 48.33 (47–50) | 49 (46–51) | +0.67 | within noise |
| negative: accepts forbidden | 2.33 (1–5) | 1.67 (0–4) | -0.67 | within noise |
| mean attempts | 2.58 (2.47–2.65) | 2.16 (2.07–2.27) | -0.42 | **better** |

## Entries whose L0.5 pass rate changed (28)

| change | entry | A passed | B passed |
|---|---|---|---|
| down | `3.1.3/S3` | 3/3 | 2/3 |
| down | `3.4.3/S1` | 2/3 | 0/3 |
| down | `SI-1.2` | 3/3 | 2/3 |
| down | `5.3/R1` | 3/3 | 1/3 |
| down | `5.5/R2` | 3/3 | 2/3 |
| down | `DD-password` | 3/3 | 2/3 |
| down | `UC-administrator-login-administrator` | 3/3 | 2/3 |
| down | `UC-administrator-manage-plug-in-options` | 3/3 | 1/3 |
| up | `1.4/S4` | 1/3 | 3/3 |
| up | `3.2.3/S2` | 2/3 | 3/3 |
| up | `3.3.3/S1` | 0/3 | 2/3 |
| up | `5.1/R1` | 0/3 | 3/3 |
| up | `5.1/R3` | 0/3 | 3/3 |
| up | `5.1/R4` | 0/3 | 2/3 |
| up | `5.1/R5` | 1/3 | 3/3 |
| up | `5.1/R6` | 0/3 | 3/3 |
| up | `5.1/R7` | 1/3 | 2/3 |
| up | `5.1/R8` | 0/3 | 3/3 |
| up | `5.1/R9` | 1/3 | 3/3 |
| up | `5.3/R3` | 1/3 | 3/3 |
| up | `5.3/R4` | 2/3 | 3/3 |
| up | `5.3/R5` | 1/3 | 3/3 |
| up | `DD-state` | 2/3 | 3/3 |
| up | `DD-location` | 0/3 | 1/3 |
| up | `UC-customer-add-item-to-cart` | 2/3 | 3/3 |
| up | `UC-administrator-change-user-properties` | 2/3 | 3/3 |
| up | `UC-administrator-install-plug-ins` | 1/3 | 3/3 |
| only in A | `1.4/I3` | 1/3 | — |

47 other entries have the same L0.5 pass rate in A and B.
