## runs/2008 - keepass/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 13.33 (13–14) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 12.00 (12–12) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 11.00 (11–11) |
| L2 components total | 14.67 (14–16) |
| end to end | 9.67 (9–10) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 9.67 (9–10) |
| L1 attempts per split spec | 3.44 (3.00–3.67) |
| minutes | 4.37 (3.66–5.00) |
| weak specs (satisfied by copies and constants) | 9.00 (9–9) |
| end to end, non-trivial spec | 3.67 (3–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 9.67 (9–10) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 1.00 (1–1) |
| po2 | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 2.33 (1–4) |
| unknown-field | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 3.9.1/S3 | first (`ComputeFoundContract`) | po3 | — |
| rep1 | 3.11.3/R15 | second (`FinalizeOutputContract`) | po3 | — |
| rep2 | 3.9.1/S3 | first (`ComputeFoundContract`) | syntax | — |
| rep3 | 3.9.1/S3 | first (`ComputeFoundContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (5): 3.1.3/R1, 3.10.3/R11, 3.11.3/R15, 3.3.1/S1, 3.9.1/S3

## runs/2008 - keepass/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 15.00 (15–15) |
| L1 chain (two components) | 1.00 (1–1) |
| L1 single (not split) | 12.00 (12–12) |
| L1 single-fallback | 2.00 (2–2) |
| L2 components implemented | 11.67 (11–12) |
| L2 components total | 16.00 (16–16) |
| end to end | 10.67 (10–11) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 10.67 (10–11) |
| L1 attempts per split spec | 3.67 (3.67–3.67) |
| minutes | 4.37 (4.00–4.65) |
| weak specs (satisfied by copies and constants) | 9.00 (9–9) |
| end to end, non-trivial spec | 3.67 (3–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 10.67 (10–11) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 1.67 (1–2) |
| po2 (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 3.00 (2–4) |
| unknown-field | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 3.9.1/S3 | first (`ComputeFoundContract`) | po3 | — |
| rep2 | 3.9.1/S3 | first (`ComputeFoundContract`) | syntax | — |
| rep3 | 3.9.1/S3 | first (`ComputeFoundContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.00 (1–1) |

Not end to end in every repetition (4): 3.10.3/R11, 3.11.3/R15, 3.3.1/S1, 3.9.1/S3
