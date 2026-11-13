## runs/2005 - microcare/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 21.00 (21–21) |
| L1 accepted | 19.00 (19–19) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 19.00 (19–19) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 13.67 (13–14) |
| L2 components total | 19.00 (19–19) |
| end to end | 13.67 (13–14) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 13.67 (13–14) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 5.65 (4.69–7.25) |
| weak specs (satisfied by copies and constants) | 10.00 (10–10) |
| end to end, non-trivial spec | 5.67 (5–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 13.67 (13–14) |
| specs, requirement | 21.00 (21–21) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| visibility | 1.00 (1–1) |
| identity | 0.67 (0–1) |
| type-error | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 5.33 (5–6) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (7): 1./S2, 2.1.1/I9, 3./I5, Design Constraints/I2, Design Constraints/S15, Design Constraints/S3#4, i/S2

## runs/2005 - microcare/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 21.00 (21–21) |
| L1 accepted | 21.00 (21–21) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 19.00 (19–19) |
| L1 single-fallback | 2.00 (2–2) |
| L2 components implemented | 16.00 (16–16) |
| L2 components total | 21.00 (21–21) |
| end to end | 16.00 (16–16) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 16.00 (16–16) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 4.80 (4.53–5.17) |
| weak specs (satisfied by copies and constants) | 10.00 (10–10) |
| end to end, non-trivial spec | 7.00 (7–7) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 16.00 (16–16) |
| specs, requirement | 21.00 (21–21) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 0.67 (0–1) |
| visibility (fell back to single) | 0.67 (0–1) |
| po2 (fell back to single) | 0.33 (0–1) |
| type-error (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 5.00 (5–5) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (5): 1./S2, 3./I5, Design Constraints/I2, Design Constraints/S3#4, i/S2
