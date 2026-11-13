## runs/1995 - gemini/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 37.00 (37–37) |
| L1 accepted | 34.33 (34–35) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 33.00 (33–33) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 27.33 (26–28) |
| L2 components total | 35.67 (35–37) |
| end to end | 26.00 (25–27) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 25.33 (25–26) |
| L1 attempts per split spec | 3.83 (3.50–4.00) |
| minutes | 7.29 (7.12–7.59) |
| weak specs (satisfied by copies and constants) | 21.00 (21–21) |
| end to end, non-trivial spec | 8.67 (8–9) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 26.00 (25–27) |
| specs, requirement | 37.00 (37–37) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 1.33 (1–2) |
| visibility | 0.67 (0–2) |
| po2 | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.67 (6–9) |
| unknown-name | 0.33 (0–1) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 2.6.3/S17 | second (`ComputeFeeContract`) | po3 | — |
| rep2 | 4.2.4.2/I3 | second (`ComputeOutputContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (10): 2.10/S4, 2.6.3/I6, 3.2.5/S6, 3.4.1/S8, 3.5.6.2/I5, 4.2.4.1/I6, 4.2.4.2/I3, 4.2.4.2/I4, 4.3.1.2.1/I1, 4.3.1.2.2/S5

## runs/1995 - gemini/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 37.00 (37–37) |
| L1 accepted | 37.00 (37–37) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 33.00 (33–33) |
| L1 single-fallback | 2.33 (2–3) |
| L2 components implemented | 29.67 (28–32) |
| L2 components total | 38.67 (38–39) |
| end to end | 28.00 (26–30) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 27.67 (26–29) |
| L1 attempts per split spec | 3.83 (3.50–4.00) |
| minutes | 7.66 (7.34–7.83) |
| weak specs (satisfied by copies and constants) | 21.00 (21–21) |
| end to end, non-trivial spec | 8.33 (8–9) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 28.00 (26–30) |
| specs, requirement | 37.00 (37–37) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 1.00 (0–2) |
| identity (fell back to single) | 1.00 (1–1) |
| visibility (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 8.00 (6–10) |
| unknown-name | 1.00 (1–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 2.6.3/S17 | second (`ComputeFeeContract`) | po3 | — |
| rep2 | 2.6.3/S17 | second (`ComputeFeeContract`) | po3 | — |
| rep2 | 4.2.4.2/I3 | second (`ComputeOutputContract`) | po3 | — |
| rep3 | 4.2.4.2/I4 | second (`FinalizeOutputContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (7): 2.6.3/I6, 3.4.1/S8, 3.5.6.2/I5, 4.2.4.1/I6, 4.2.4.2/I4, 4.3.1.2.1/I1, 4.3.1.2.2/S5
