## runs/2006 - eirene sys 15/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 55.00 (55–55) |
| L1 accepted | 48.00 (48–48) |
| L1 chain (two components) | 3.00 (3–3) |
| L1 single (not split) | 45.00 (45–45) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 38.33 (38–39) |
| L2 components total | 51.00 (51–51) |
| end to end | 36.33 (36–37) |
| end to end, chain | 1.00 (1–1) |
| end to end, single | 35.33 (35–36) |
| L1 attempts per split spec | 4.10 (3.90–4.20) |
| minutes | 14.67 (13.78–16.33) |
| weak specs (satisfied by copies and constants) | 22.00 (22–22) |
| end to end, non-trivial spec | 19.33 (19–20) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.11 (5.00–5.33) |
| end to end, requirement | 36.33 (36–37) |
| specs, requirement | 55.00 (55–55) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 4.00 (4–4) |
| po2 | 2.00 (2–2) |
| unknown-field | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 12.00 (12–12) |
| type-error | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 5.3.12/S1 | first (`AddMessageContract`) | po3 | — |
| rep2 | 5.3.12/S1 | first (`ComputeNewMessageContract`) | po3 | — |
| rep3 | 5.3.12/S1 | first (`AddMessageContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.00 (3–3) |

Not end to end in every repetition (18): 11.3.15/S1, 13.3.2/S1, 14.2.4/S1, 4.3.5/S1, 4.5.36/S1, 4.5.9/S1, 5.3.12/S1, 5.4.9/S1, 5.5.2/S1, 5.5.24/S1, 5.6.3/S1, 5.6.4i/S1, 5.7.9/S1, 7.3.3/S1, 8.3.2/S1, 9.2.1/S1, 9.2.3/S1, 9.2.6/S1

## runs/2006 - eirene sys 15/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 55.00 (55–55) |
| L1 accepted | 55.00 (55–55) |
| L1 chain (two components) | 3.67 (3–4) |
| L1 single (not split) | 45.00 (45–45) |
| L1 single-fallback | 6.33 (6–7) |
| L2 components implemented | 44.33 (44–45) |
| L2 components total | 58.67 (58–59) |
| end to end | 41.67 (41–42) |
| end to end, chain | 1.33 (1–2) |
| end to end, single | 40.33 (39–41) |
| L1 attempts per split spec | 3.83 (3.50–4.00) |
| minutes | 15.49 (14.31–16.62) |
| weak specs (satisfied by copies and constants) | 22.00 (22–22) |
| end to end, non-trivial spec | 21.33 (20–22) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.19 (5.00–5.33) |
| end to end, requirement | 41.67 (41–42) |
| specs, requirement | 55.00 (55–55) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 4.33 (4–5) |
| unknown-field (fell back to single) | 1.00 (1–1) |
| po2 (fell back to single) | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 13.67 (13–15) |
| type-error | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 4.3.5/S1 | second (`FinalizeOutcomeContract`) | po3 | — |
| rep1 | 5.3.12/S1 | first (`AddMessageContract`) | po3 | — |
| rep2 | 5.3.12/S1 | first (`ComputeNewMessageContract`) | po3 | — |
| rep3 | 5.3.12/S1 | first (`AddMessageContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.67 (3–4) |

Not end to end in every repetition (11): 13.3.2/S1, 4.3.5/S1, 4.5.36/S1, 4.5.9/S1, 5.3.12/S1, 5.5.2/S1, 5.7.9/S1, 8.3.2/S1, 9.2.1/S1, 9.2.3/S1, 9.2.6/S1
