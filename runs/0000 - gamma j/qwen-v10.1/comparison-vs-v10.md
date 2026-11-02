# `qwen-v10` (3 reps) → `qwen-v10.1` (3 reps)

Document: `0000 - gamma j.xml`

- A: harness_version `v10`, model_id `qwen2.5-7b-instruct`, temperature `0.2`, prompt_hash `a4ace6f72b38`, git_commit `f8af89f`, seeds [42, 43, 44]
- B: harness_version `v10.1`, model_id `qwen2.5-7b-instruct`, temperature `0.2`, prompt_hash `a4ace6f72b38`, git_commit `b01f013`, seeds [42, 43, 44]

Mean (min–max) over repetitions. A change is real only if the means differ by more than the spread (max − min) of either run.

| metric | A: qwen-v10 | B: qwen-v10.1 | Δ mean | verdict |
|---|---|---|---|---|
| entries | 74 (74–74) | 74 (74–74) | +0.00 | same |
| compiles | 65 (65–65) | 67 (66–68) | +2.00 | within noise |
| checked (L0 OK) | 62 (60–63) | 63.33 (59–67) | +1.33 | within noise |
| L0.5 pass | 60 (57–63) | 61 (57–63) | +1.00 | within noise |
| L0.5 flag | 4 (2–6) | 4.33 (3–5) | +0.33 | within noise |
| L0.5 fail | 10 (9–11) | 8.67 (6–12) | -1.33 | within noise |
| negative: rejects | 47 (44–50) | 49 (46–51) | +2.00 | within noise |
| negative: accepts forbidden | 0.67 (0–1) | 1.67 (0–4) | +1.00 | within noise |
| mean attempts | 2.17 (2.08–2.23) | 2.16 (2.07–2.27) | -0.01 | within noise |

## Entries whose L0.5 pass rate changed (15)

| change | entry | A passed | B passed |
|---|---|---|---|
| down | `3.1.3/S2` | 3/3 | 2/3 |
| down | `3.3.3/S1` | 3/3 | 2/3 |
| down | `3.3.3/S3` | 2/3 | 1/3 |
| down | `3.4.3/S1` | 1/3 | 0/3 |
| down | `5.1/R7` | 3/3 | 2/3 |
| down | `5.5/R2` | 3/3 | 2/3 |
| down | `UC-customer-register-customer` | 3/3 | 2/3 |
| up | `3.3.3/S2` | 0/3 | 3/3 |
| up | `5.3/R4` | 2/3 | 3/3 |
| up | `DD-password` | 1/3 | 2/3 |
| up | `UC-customer-login-customer` | 2/3 | 3/3 |
| up | `UC-administrator-login-administrator` | 1/3 | 2/3 |
| up | `UC-administrator-install-patch-process` | 2/3 | 3/3 |
| up | `UC-sales-person-add-product` | 2/3 | 3/3 |
| up | `UC-sales-person-remove-product` | 2/3 | 3/3 |

59 other entries have the same L0.5 pass rate in A and B.
