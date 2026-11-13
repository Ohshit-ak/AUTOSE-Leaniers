## runs/0000 - gamma j/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 61.00 (61–61) |
| L1 accepted | 58.00 (58–58) |
| L1 chain (two components) | 1.00 (1–1) |
| L1 single (not split) | 57.00 (57–57) |
| L1 single-fallback | 0.00 (0–0) |
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

## runs/0000 - gamma j/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 61.00 (61–61) |
| L1 accepted | 61.00 (61–61) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 57.00 (57–57) |
| L1 single-fallback | 2.67 (2–3) |
| L2 components implemented | 55.33 (55–56) |
| L2 components total | 62.33 (62–63) |
| end to end | 54.00 (54–54) |
| end to end, chain | 1.33 (1–2) |
| end to end, single | 52.67 (52–53) |
| L1 attempts per split spec | 3.83 (3.50–4.00) |
| minutes | 12.33 (11.76–13.01) |
| weak specs (satisfied by copies and constants) | 24.00 (24–24) |
| end to end, non-trivial spec | 31.00 (31–31) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 22.00 (22–22) |
| specs, requirement | 27.00 (27–27) |
| end to end, use_case | 15.00 (15–15) |
| specs, use_case | 17.00 (17–17) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 2.00 (2–2) |
| po2 (fell back to single) | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.00 (7–7) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (7): 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 5.3/R5, SI-1.2, UC-administrator-add-user, UC-administrator-remove-user

## runs/0000 - gamma j/qwen-chain-v3

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 61.00 (61–61) |
| L1 accepted | 44.33 (44–45) |
| L1 chain (two components) | 6.33 (6–7) |
| L1 single (not split) | 38.00 (38–38) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 45.00 (43–47) |
| L2 components total | 50.67 (50–52) |
| end to end | 38.67 (37–40) |
| end to end, chain | 4.00 (3–5) |
| end to end, single | 34.67 (34–35) |
| L1 attempts per split spec | 4.38 (4.35–4.43) |
| minutes | 16.46 (14.70–18.52) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 5) | 4.94 (4.83–5.00) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 15.33 (14–16) |
| specs, requirement | 27.00 (27–27) |
| end to end, use_case | 6.33 (6–7) |
| specs, use_case | 17.00 (17–17) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po1 | 4.67 (4–6) |
| visibility | 3.67 (3–4) |
| identity | 3.33 (3–4) |
| po2 | 1.67 (1–2) |
| unknown-name | 1.33 (1–2) |
| type-error | 1.00 (0–3) |
| unknown-field | 0.67 (0–1) |
| syntax | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 3.00 (2–4) |
| unknown-field | 2.00 (2–2) |
| type-error | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 3.2.3/S1 | second (`CopyCategoriesContract`) | unknown-field | — |
| rep1 | UC-customer-add-item-to-cart | second (`CookieUpdateContract`) | unknown-field | — |
| rep2 | 3.2.3/S1 | second (`CopyCategoriesContract`) | unknown-field | — |
| rep2 | UC-customer-add-item-to-cart | second (`CookieGenerationContract`) | unknown-field | — |
| rep3 | 3.2.3/S1 | second (`ReorderCategoriesContract`) | unknown-field | — |
| rep3 | 5.1/R5 | second (`ProcessResultsContract`) | po3 | — |
| rep3 | UC-customer-add-item-to-cart | second (`UpdateCookieContract`) | unknown-field | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| single-step spec (not split now) | 5.33 (5–6) |
| real decomposition | 1.00 (1–1) |

Not end to end in every repetition (21): 1.4/S3, 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 3.2.3/S1, 3.2.3/S2, 3.3.3/S1, 3.3.3/S2, 5.3/R4, 5.3/R5, SI-1.2, UC-administrator-add-user, UC-administrator-change-user-properties, UC-administrator-install-patch-process, UC-administrator-remove-plug-ins, UC-administrator-remove-user, UC-customer-add-item-to-cart, UC-customer-edit-customer-details, UC-customer-login-customer, UC-sales-person-add-product, UC-sales-person-update-product-attributes
