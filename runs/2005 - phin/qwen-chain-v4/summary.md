## runs/2005 - phin/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 31.00 (31–31) |
| L1 accepted | 28.00 (28–28) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 28.00 (28–28) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 14.00 (14–14) |
| L2 components total | 28.00 (28–28) |
| end to end | 14.00 (14–14) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 14.00 (14–14) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 9.71 (9.57–9.92) |
| weak specs (satisfied by copies and constants) | 13.00 (13–13) |
| end to end, non-trivial spec | 4.00 (4–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 14.00 (14–14) |
| specs, requirement | 31.00 (31–31) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 1.67 (1–2) |
| visibility | 1.00 (1–1) |
| type-error | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 13.67 (13–14) |
| unknown-field | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (17): 2.2.1.3/S1, 2.2.2.1/S1, 2.2.4.3a/S1, 2.2.6.10/S1, 2.2.6.2/S1, 2.2.6.3/S1, 2.2.6.6/S1, 2.2.6.7/S1, 2.2.6.9/S1, 2.3.1.1/S1, 2.3.3.3/S1, 2.4.4/S1, 2.5.1/S1, 2.5.10/S1, 2.5.12/S1, 2.5.7/S1, 2.5/S1

## runs/2005 - phin/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 31.00 (31–31) |
| L1 accepted | 31.00 (31–31) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 28.00 (28–28) |
| L1 single-fallback | 3.00 (3–3) |
| L2 components implemented | 15.00 (15–15) |
| L2 components total | 31.00 (31–31) |
| end to end | 15.00 (15–15) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 15.00 (15–15) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 11.21 (10.27–12.58) |
| weak specs (satisfied by copies and constants) | 13.00 (13–13) |
| end to end, non-trivial spec | 4.00 (4–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 15.00 (15–15) |
| specs, requirement | 31.00 (31–31) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 1.67 (1–2) |
| visibility (fell back to single) | 1.00 (1–1) |
| unknown-name (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 16.00 (16–16) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (16): 2.2.1.3/S1, 2.2.2.1/S1, 2.2.4.3a/S1, 2.2.6.10/S1, 2.2.6.2/S1, 2.2.6.3/S1, 2.2.6.6/S1, 2.2.6.7/S1, 2.2.6.9/S1, 2.3.1.1/S1, 2.3.3.3/S1, 2.4.4/S1, 2.5.1/S1, 2.5.10/S1, 2.5.12/S1, 2.5.7/S1
