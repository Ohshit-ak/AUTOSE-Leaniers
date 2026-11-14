## runs/0000 - gamma j/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 59.00 (59–59) |
| L1 accepted | 58.00 (57–59) |
| L1 chain (two components) | 3.67 (1–6) |
| L1 single (not split) | 50.00 (50–50) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 4.33 (3–7) |
| L2 components implemented | 52.00 (51–53) |
| L2 components total | 61.67 (59–65) |
| end to end | 49.33 (48–51) |
| end to end, chain | 2.00 (1–3) |
| end to end, single | 47.33 (46–50) |
| L1 attempts per split spec | 2.72 (2.17–3.00) |
| minutes | 15.13 (13.18–16.41) |
| weak specs (satisfied by copies and constants) | 18.00 (18–18) |
| end to end, non-trivial spec | 33.33 (33–34) |
| weak specs that only pass data through (copy-ok) | 2.00 (2–2) |
| end to end, copy-ok spec | 2.00 (2–2) |
| L2 implemented by the harness skeleton alone | 38.00 (38–38) |
| L2 implemented with the model | 14.00 (13–15) |
| L2 result fields written by the harness | 64.00 (60–68) |
| L2 result fields written by the model | 18.33 (17–19) |
| end to end, non-trivial spec, model wrote code | 8.33 (8–9) |
| repair loops stopped early (L1 + L2) | 6.33 (4–8) |
| L1 chain with a repaired second `pre` | 0.67 (0–1) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 23.33 (23–24) |
| specs, requirement | 30.00 (30–30) |
| end to end, use_case | 9.00 (8–10) |
| specs, use_case | 12.00 (12–12) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.00 (0–2) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 9.67 (7–12) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | UC-administrator-add-user | second (`ApplyRoleAndPrivilegesContract`) | po3 | — |
| rep3 | 5.5/R1 | first (`ComputeResultsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.67 (1–6) |

Not end to end in every repetition (8): 3.1.3/S1, 3.1.3/S2, 3.4.3/S2, 5.3/R1, 5.3/R5, 5.5/R1, UC-customer-edit-customer-details, UC-sales-person-remove-product

## runs/0000 - gamma j/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 59.00 (59–59) |
| L1 accepted | 59.00 (59–59) |
| L1 chain (two components) | 3.00 (2–4) |
| L1 single (not split) | 50.00 (50–50) |
| L1 single-fallback | 2.00 (1–3) |
| L1 not decomposable (identity split → single) | 4.00 (4–4) |
| L2 components implemented | 51.33 (50–53) |
| L2 components total | 62.00 (61–63) |
| end to end | 49.67 (49–50) |
| end to end, chain | 1.33 (1–2) |
| end to end, single | 48.33 (48–49) |
| L1 attempts per split spec | 2.73 (2.00–3.20) |
| minutes | 14.71 (13.06–15.88) |
| weak specs (satisfied by copies and constants) | 18.00 (18–18) |
| end to end, non-trivial spec | 33.00 (33–33) |
| weak specs that only pass data through (copy-ok) | 2.00 (2–2) |
| end to end, copy-ok spec | 2.00 (2–2) |
| L2 implemented by the harness skeleton alone | 37.67 (37–38) |
| L2 implemented with the model | 13.67 (12–16) |
| L2 result fields written by the harness | 61.00 (60–63) |
| L2 result fields written by the model | 17.67 (16–20) |
| end to end, non-trivial spec, model wrote code | 8.00 (8–8) |
| repair loops stopped early (L1 + L2) | 5.33 (4–7) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 23.67 (23–24) |
| specs, requirement | 30.00 (30–30) |
| end to end, use_case | 9.00 (9–9) |
| specs, use_case | 12.00 (12–12) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 2.00 (1–3) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 10.33 (10–11) |
| unknown-name | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep3 | 5.5/R1 | first (`ComputeResultsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.00 (2–4) |

Not end to end in every repetition (9): 3.1.3/S1, 3.1.3/S2, 3.4.3/S2, 5.3/R1, 5.3/R5, 5.5/R1, UC-customer-edit-customer-details, UC-sales-person-login-sales-person, UC-sales-person-remove-product

## runs/0000 - gamma j/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 61.00 (61–61) |
| L1 accepted | 60.33 (60–61) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 57.00 (57–57) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.00 (1–3) |
| L2 components implemented | 54.33 (54–55) |
| L2 components total | 61.67 (61–62) |
| end to end | 53.00 (53–53) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 52.33 (52–53) |
| L1 attempts per split spec | 2.33 (1–3) |
| minutes | 10.66 (9.74–11.30) |
| weak specs (satisfied by copies and constants) | 24.00 (24–24) |
| end to end, non-trivial spec | 30.67 (30–31) |
| L2 implemented by the harness skeleton alone | 36.33 (36–37) |
| L2 implemented with the model | 18.00 (17–19) |
| L2 result fields written by the harness | 58.00 (58–58) |
| L2 result fields written by the model | 21.67 (21–23) |
| end to end, non-trivial spec, model wrote code | 8.67 (8–9) |
| repair loops stopped early (L1 + L2) | 2.67 (2–3) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 21.33 (21–22) |
| specs, requirement | 27.00 (27–27) |
| end to end, use_case | 14.67 (14–15) |
| specs, use_case | 17.00 (17–17) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.00 (6–6) |
| unknown-field | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | UC-customer-login-customer | second (`GenerateOutputContract`) | po3 | — |
| rep3 | 5.1/R5 | second (`ProcessResultsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (7): 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 5.3/R5, SI-1.2, UC-administrator-add-user, UC-administrator-remove-user

## runs/0000 - gamma j/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 61.00 (61–61) |
| L1 accepted | 58.00 (58–58) |
| L1 chain (two components) | 1.00 (1–1) |
| L1 single (not split) | 57.00 (57–57) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 53.67 (53–54) |
| L2 components total | 59.00 (59–59) |
| end to end | 52.67 (52–53) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 52.00 (52–52) |
| L1 attempts per split spec | 4.00 (4–4) |
| minutes | 11.51 (10.47–13.07) |
| weak specs (satisfied by copies and constants) | 24.00 (24–24) |
| end to end, non-trivial spec | 30.67 (30–31) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 21.00 (21–21) |
| specs, requirement | 27.00 (27–27) |
| end to end, use_case | 14.67 (14–15) |
| specs, use_case | 17.00 (17–17) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 2.00 (2–2) |
| po2 | 0.67 (0–1) |
| type-error | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 5.33 (5–6) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | UC-customer-login-customer | second (`GenerateOutputContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.00 (1–1) |

Not end to end in every repetition (8): 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 5.1/R5, 5.3/R5, SI-1.2, UC-administrator-add-user, UC-administrator-remove-user
