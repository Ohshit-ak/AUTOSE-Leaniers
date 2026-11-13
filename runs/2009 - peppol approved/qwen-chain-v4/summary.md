## runs/2009 - peppol approved/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 42.00 (42–42) |
| L1 accepted | 41.00 (41–41) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 41.00 (41–41) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 27.00 (26–28) |
| L2 components total | 41.00 (41–41) |
| end to end | 27.00 (26–28) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 27.00 (26–28) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 9.77 (8.40–11.45) |
| weak specs (satisfied by copies and constants) | 16.00 (16–16) |
| end to end, non-trivial spec | 13.00 (12–14) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 27.00 (26–28) |
| specs, requirement | 42.00 (42–42) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 10.67 (10–11) |
| unknown-field | 2.00 (2–2) |
| unknown-name | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (14): 0/I6, 1.1/I2, 1.2/S34, 1.2/S8, 3.1.2.1/S2, 3.1.2.2/S2, 3.2.3.1/S1, 3.2.4.10/S4, 3.3.2.3/S1, 3.4.2.3/S1, 3.4.2.4/S3, 4.2/S10, 4.4.2/S1, 5.1/S2

## runs/2009 - peppol approved/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 42.00 (42–42) |
| L1 accepted | 42.00 (42–42) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 41.00 (41–41) |
| L1 single-fallback | 1.00 (1–1) |
| L2 components implemented | 27.33 (26–28) |
| L2 components total | 42.00 (42–42) |
| end to end | 27.33 (26–28) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 27.33 (26–28) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 11.45 (10.98–11.90) |
| weak specs (satisfied by copies and constants) | 16.00 (16–16) |
| end to end, non-trivial spec | 13.33 (12–14) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 27.33 (26–28) |
| specs, requirement | 42.00 (42–42) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 10.67 (10–11) |
| unknown-field | 1.67 (1–3) |
| unknown-name | 1.33 (1–2) |
| syntax | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (14): 0/I6, 1.1/I2, 1.2/S34, 1.2/S8, 3.1.2.1/S2, 3.1.2.2/S2, 3.2.3.1/S1, 3.2.3.2/S1, 3.2.4.10/S4, 3.3.2.3/S1, 3.4.2.4/S3, 4.2/S10, 4.4.2/S1, 5.1/S2
