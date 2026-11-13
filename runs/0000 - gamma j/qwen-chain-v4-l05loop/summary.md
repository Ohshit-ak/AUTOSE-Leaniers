## runs/0000 - gamma j/qwen-chain-v4-l05loop

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 62.00 (62–62) |
| L1 accepted | 56.33 (56–57) |
| L1 chain (two components) | 0.33 (0–1) |
| L1 single (not split) | 56.00 (56–56) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 47.33 (47–48) |
| L2 components total | 56.67 (56–58) |
| end to end | 47.33 (47–48) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 47.33 (47–48) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 13.95 (13.12–15.15) |
| weak specs (satisfied by copies and constants) | 23.00 (23–23) |
| end to end, non-trivial spec | 26.00 (26–26) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 20.33 (20–21) |
| specs, requirement | 31.00 (31–31) |
| end to end, use_case | 10.00 (10–10) |
| specs, use_case | 14.00 (14–14) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 4.67 (4–5) |
| identity | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 9.33 (8–11) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.33 (0–1) |

Not end to end in every repetition (14): 1.4/S3, 3.1.3/S1, 3.1.3/S2, 3.2.3/S1, 3.4.3/S1, 5.3/R1, 5.3/R3, 5.3/R4, 5.3/R5, 5.5/R1, UC-administrator-install-patch-process, UC-administrator-install-plug-ins, UC-administrator-remove-plug-ins, UC-administrator-remove-user

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
