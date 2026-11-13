## runs/0000 - cctns/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 10.00 (10–10) |
| L1 accepted | 9.00 (9–9) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 9.00 (9–9) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 6.00 (6–6) |
| L2 components total | 9.00 (9–9) |
| end to end | 6.00 (6–6) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 6.00 (6–6) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 3.33 (2.99–4.00) |
| weak specs (satisfied by copies and constants) | 4.00 (4–4) |
| end to end, non-trivial spec | 2.00 (2–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 6.00 (6–6) |
| specs, requirement | 10.00 (10–10) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 3.00 (3–3) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (4): 3/registration/S1, 4/audit-module/R5, 4/system-availability/R4, 5/S7

## runs/0000 - cctns/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 10.00 (10–10) |
| L1 accepted | 10.00 (10–10) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 9.00 (9–9) |
| L1 single-fallback | 1.00 (1–1) |
| L2 components implemented | 6.00 (6–6) |
| L2 components total | 10.00 (10–10) |
| end to end | 6.00 (6–6) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 6.00 (6–6) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 3.37 (3.05–3.83) |
| weak specs (satisfied by copies and constants) | 4.00 (4–4) |
| end to end, non-trivial spec | 2.00 (2–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 6.00 (6–6) |
| specs, requirement | 10.00 (10–10) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 3.00 (3–3) |
| unknown-field | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (4): 3/registration/S1, 4/audit-module/R5, 4/system-availability/R4, 5/S7
