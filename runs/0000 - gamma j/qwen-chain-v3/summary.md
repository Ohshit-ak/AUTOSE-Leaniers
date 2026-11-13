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

### Accepted two-component architectures under the v3 static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 6.33 (6–7) |

Not end to end in every repetition (21): 1.4/S3, 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 3.2.3/S1, 3.2.3/S2, 3.3.3/S1, 3.3.3/S2, 5.3/R4, 5.3/R5, SI-1.2, UC-administrator-add-user, UC-administrator-change-user-properties, UC-administrator-install-patch-process, UC-administrator-remove-plug-ins, UC-administrator-remove-user, UC-customer-add-item-to-cart, UC-customer-edit-customer-details, UC-customer-login-customer, UC-sales-person-add-product, UC-sales-person-update-product-attributes

## runs/0000 - gamma j/qwen-chain-v3-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 61.00 (61–61) |
| L1 accepted | 61.00 (61–61) |
| L1 chain (two components) | 7.00 (6–8) |
| L1 single (not split) | 38.00 (38–38) |
| L1 single-fallback | 16.00 (15–17) |
| L2 components implemented | 57.67 (56–59) |
| L2 components total | 68.00 (67–69) |
| end to end | 50.67 (50–51) |
| end to end, chain | 4.67 (4–5) |
| end to end, single | 46.00 (46–46) |
| L1 attempts per split spec | 4.28 (4.17–4.43) |
| minutes | 20.52 (18.31–22.28) |
| strength of chain architectures (of 5) | 5.00 (5–5) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 20.67 (20–21) |
| specs, requirement | 27.00 (27–27) |
| end to end, use_case | 13.00 (13–13) |
| specs, use_case | 17.00 (17–17) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 4.33 (4–5) |
| po1 (fell back to single) | 4.33 (3–5) |
| visibility (fell back to single) | 3.00 (3–3) |
| unknown-name (fell back to single) | 1.67 (1–2) |
| po2 (fell back to single) | 1.00 (0–2) |
| type-error (fell back to single) | 1.00 (0–2) |
| syntax (fell back to single) | 0.33 (0–1) |
| unknown-field (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.67 (5–8) |
| unknown-field | 2.33 (2–3) |
| type-error | 0.67 (0–1) |
| syntax | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 3.1.3/S1 | second (`UpdateProfileContract`) | po3 | — |
| rep1 | 3.2.3/S1 | second (`ReorderCategoriesContract`) | unknown-field | — |
| rep1 | UC-customer-add-item-to-cart | second (`UpdateCookieContract`) | unknown-field | — |
| rep2 | 3.2.3/S1 | second (`ReorderCategoriesContract`) | unknown-field | — |
| rep2 | UC-customer-add-item-to-cart | second (`CookieGenerationContract`) | unknown-field | — |
| rep3 | 3.2.3/S1 | second (`ReorderCategoriesContract`) | unknown-field | — |
| rep3 | UC-customer-add-item-to-cart | second (`CookieContract`) | unknown-field | — |

### Accepted two-component architectures under the v3 static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 7.00 (6–8) |

Not end to end in every repetition (10): 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 3.2.3/S1, 5.3/R5, SI-1.2, UC-administrator-add-user, UC-administrator-remove-plug-ins, UC-administrator-remove-user, UC-customer-add-item-to-cart

## runs/0000 - gamma j/qwen-e2e-v2

1 repetition(s): qwen-e2e-v2 — a single run, so there is no spread and no difference to another run can be called real

| metric | value |
|---|---|
| specs | 61 |
| L1 accepted | 29 |
| L1 chain (two components) | 29 |
| L1 single (not split) | 0 |
| L1 single-fallback | 0 |
| L2 components implemented | 48 |
| L2 components total | 58 |
| end to end | 19 |
| end to end, chain | 19 |
| end to end, single | 0 |
| L1 attempts per split spec | 3.18 |
| minutes | 65.06 |
| end to end, data_constraint | 0 |
| specs, data_constraint | 17 |
| end to end, requirement | 12 |
| specs, requirement | 27 |
| end to end, use_case | 7 |
| specs, use_case | 17 |

### L1 failures by class

| class | count |
|---|---|
| type-error | 20 |
| proof | 5 |
| unknown-field | 4 |
| unknown-name | 2 |
| syntax | 1 |

### L2 component failures by class

| class | count |
|---|---|
| proof | 6 |
| unknown-field | 3 |
| type-error | 1 |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| qwen-e2e-v2 | 5.1/R4 | first (`ValidateContract`) | type-error | implementation written backwards: `ValidateContractImpl : Mid → Input` for `ValidateContract : Contract Input Mid` |
| qwen-e2e-v2 | 5.1/R6 | first (`ValidateContract`) | unknown-field | implementation written backwards: `ValidateContractImpl : Mid → Input` for `ValidateContract : Contract Input Mid` |
| qwen-e2e-v2 | 5.1/R8 | first (`ValidateContract`) | unknown-field | implementation written backwards: `ValidateContractImpl : Mid → Input` for `ValidateContract : Contract Input Mid` |
| qwen-e2e-v2 | 5.1/R9 | first (`ValidateContract`) | unknown-field | implementation written backwards: `ValidateContractImpl : Mid → Input` for `ValidateContract : Contract Input Mid` |
| qwen-e2e-v2 | 5.5/R5 | first (`ValidateEmailContract`) | proof | contract not implementable: `ValidateEmailContract` promises `m.email.toList.all Char.isAlphanum = true` about a field it copies from the input |
| qwen-e2e-v2 | DD-price | first (`ValidateContract`) | proof | contract not implementable: `ValidateContract` promises `m.value ≤ 9999` about a field it copies from the input |
| qwen-e2e-v2 | DD-shipping-price | first (`ValidateContract`) | proof | contract not implementable: `ValidateContract` promises `m.value ≤ 9999` about a field it copies from the input |
| qwen-e2e-v2 | DD-total | first (`ValidateContract`) | proof | contract not implementable: `ValidateContract` promises `m.value ≤ 9999` about a field it copies from the input |
| qwen-e2e-v2 | UC-administrator-remove-user | first (`ValidateContract`) | proof | — |
| qwen-e2e-v2 | 3.1.3/S3 | first (`ValidateContract`) | proof | contract not implementable: `ValidateContract` promises `∀ p ∈ m.profiles, p.name ≠ "" ∧
                     p.email ≠ "" ∧
                     p.creditCards.Nodup ∧
                     p.addresses.Nodup` about a field it copies from the input |

### Accepted two-component architectures under the v3 static check

| verdict | count |
|---|---|
| single-step spec (v3 does not split it) | 17 |
| identity | 12 |

Not end to end in this run (42): 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 3.3.3/S2, 5.1/R4, 5.1/R5, 5.1/R6, 5.1/R7, 5.1/R8, 5.1/R9, 5.3/R3, 5.3/R4, 5.3/R5, 5.5/R5, DD-city, DD-credit-card-no, DD-e-mail-id, DD-item-id, DD-item-name, DD-name, DD-order-no, DD-password, DD-price, DD-quantity, DD-shipping-price, DD-state, DD-text-description, DD-total, DD-tracking-no, DD-user-id, DD-zip-code, SI-1.2, UC-administrator-add-user, UC-administrator-change-user-properties, UC-administrator-install-patch-process, UC-administrator-install-plug-ins, UC-administrator-remove-plug-ins, UC-administrator-remove-user, UC-customer-add-item-to-cart, UC-customer-edit-customer-details, UC-customer-login-customer, UC-sales-person-login-sales-person
