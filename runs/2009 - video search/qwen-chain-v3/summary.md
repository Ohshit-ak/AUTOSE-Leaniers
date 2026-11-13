## runs/2009 - video search/qwen-chain-v3

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 8.67 (8–9) |
| L1 chain (two components) | 3.67 (3–4) |
| L1 single (not split) | 5.00 (5–5) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 9.33 (8–10) |
| L2 components total | 12.33 (11–13) |
| end to end | 6.67 (6–7) |
| end to end, chain | 1.67 (1–2) |
| end to end, single | 5.00 (5–5) |
| L1 attempts per split spec | 3.83 (3.70–4.00) |
| minutes | 6.78 (6.67–6.85) |
| strength of chain architectures (of 5) | 4.19 (4.00–4.33) |
| end to end, requirement | 6.67 (6–7) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 4.00 (4–4) |
| identity | 1.33 (1–2) |
| po1 | 0.67 (0–1) |
| visibility | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 2.33 (1–4) |
| unknown-field | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | REQ-7#2 | second (`ShowResultsContract`) | po3 | — |
| rep2 | REQ-3#2 | second (`ResultsCheckContract`) | po3 | — |
| rep3 | REQ-3 | second (`ShowResultsContract`) | po3 | — |

### Accepted two-component architectures under the v3 static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.67 (3–4) |

Not end to end in every repetition (8): REQ-1, REQ-2, REQ-3, REQ-3#2, REQ-4, REQ-4#2, REQ-4#3, REQ-6

## runs/2009 - video search/qwen-chain-v3-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 15.00 (15–15) |
| L1 chain (two components) | 4.33 (3–6) |
| L1 single (not split) | 5.00 (5–5) |
| L1 single-fallback | 5.67 (4–7) |
| L2 components implemented | 13.33 (12–15) |
| L2 components total | 19.33 (18–21) |
| end to end | 9.33 (7–11) |
| end to end, chain | 2.00 (1–3) |
| end to end, single | 7.33 (6–8) |
| L1 attempts per split spec | 3.53 (2.90–3.90) |
| minutes | 8.14 (7.83–8.50) |
| strength of chain architectures (of 5) | 4.11 (4.00–4.33) |
| end to end, requirement | 9.33 (7–11) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 3.00 (2–4) |
| po1 (fell back to single) | 1.33 (1–2) |
| identity (fell back to single) | 1.00 (1–1) |
| syntax (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 5.00 (3–8) |
| unknown-field | 0.67 (0–1) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | REQ-4#3 | second (`CollectResultsContract`) | po3 | — |
| rep2 | REQ-4#2 | second (`FormatResultsContract`) | unknown-field | — |
| rep3 | REQ-2 | second (`ApplyUpdatesContract`) | unknown-field | — |
| rep3 | REQ-3 | second (`FormatResultsContract`) | po3 | — |
| rep3 | REQ-7#2 | second (`ShowResultsContract`) | po3 | — |
| rep3 | REQ-4#3 | second (`CollectResultsContract`) | po3 | — |

### Accepted two-component architectures under the v3 static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 4.33 (3–6) |

Not end to end in every repetition (3): REQ-1, REQ-4, REQ-6

## runs/2009 - video search/qwen-e2e-v2

1 repetition(s): qwen-e2e-v2 — a single run, so there is no spread and no difference to another run can be called real

| metric | value |
|---|---|
| specs | 14 |
| L1 accepted | 9 |
| L1 chain (two components) | 9 |
| L1 single (not split) | 0 |
| L1 single-fallback | 0 |
| L2 components implemented | 16 |
| L2 components total | 18 |
| end to end | 7 |
| end to end, chain | 7 |
| end to end, single | 0 |
| L1 attempts per split spec | 2.50 |
| minutes | 11.61 |
| end to end, requirement | 7 |
| specs, requirement | 14 |

### L1 failures by class

| class | count |
|---|---|
| type-error | 2 |
| unknown-name | 1 |
| unknown-field | 1 |
| proof | 1 |

### L2 component failures by class

| class | count |
|---|---|
| unknown-field | 1 |
| type-error | 1 |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| qwen-e2e-v2 | REQ-1#3 | first (`ValidateContract`) | type-error | implementation written backwards: `ValidateContractImpl : Mid → Input` for `ValidateContract : Contract Input Mid` |
| qwen-e2e-v2 | REQ-2#3 | first (`ValidateContract`) | unknown-field | implementation written backwards: `ValidateContractImpl : Mid → Input` for `ValidateContract : Contract Input Mid` |

### Accepted two-component architectures under the v3 static check

| verdict | count |
|---|---|
| single-step spec (v3 does not split it) | 4 |
| identity | 4 |
| real decomposition | 1 |

Not end to end in this run (7): REQ-1, REQ-1#3, REQ-2#3, REQ-4, REQ-4#3, REQ-5#3, REQ-7#2
