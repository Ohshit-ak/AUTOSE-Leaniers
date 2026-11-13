## runs/1999 - tcs/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 43.00 (43–43) |
| L1 accepted | 39.00 (39–39) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 39.00 (39–39) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 33.33 (33–34) |
| L2 components total | 39.00 (39–39) |
| end to end | 33.33 (33–34) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 33.33 (33–34) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 9.65 (9.46–9.90) |
| weak specs (satisfied by copies and constants) | 20.00 (20–20) |
| end to end, non-trivial spec | 16.33 (16–17) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 33.33 (33–34) |
| specs, requirement | 43.00 (43–43) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 1.67 (1–2) |
| po2 | 1.00 (1–1) |
| unknown-field | 1.00 (1–1) |
| type-error | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 5.00 (5–5) |
| unknown-name | 0.67 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (9): 3.14/S5, 3.2.1.1.1/S2, 3.2.1/S6, 3.2.2.1.1.1/S1, 3.2.2.1.2/S1, 3.2.2.2.1/S1, 3.2.2.3.1/S1, 3.2.5.2.1/S5, 3.2.5.2/S1

## runs/1999 - tcs/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 43.00 (43–43) |
| L1 accepted | 43.00 (43–43) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 39.00 (39–39) |
| L1 single-fallback | 4.00 (4–4) |
| L2 components implemented | 35.00 (35–35) |
| L2 components total | 43.00 (43–43) |
| end to end | 35.00 (35–35) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 35.00 (35–35) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 13.30 (10.97–16.62) |
| weak specs (satisfied by copies and constants) | 20.00 (20–20) |
| end to end, non-trivial spec | 17.33 (17–18) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 35.00 (35–35) |
| specs, requirement | 43.00 (43–43) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 1.67 (1–2) |
| po2 (fell back to single) | 1.00 (0–2) |
| unknown-field (fell back to single) | 1.00 (1–1) |
| type-error (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.00 (7–7) |
| unknown-name | 0.67 (0–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (7): 3.2.1.1.1/S2, 3.2.1/S6, 3.2.2.1.1.1/S1, 3.2.2.1.2/S1, 3.2.2.2.1/S1, 3.2.2.3.1/S1, 3.2.5.2.1/S5
