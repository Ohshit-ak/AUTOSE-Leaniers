## runs/0000 - cctns/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 13.00 (13–13) |
| L1 accepted | 12.67 (12–13) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 10.00 (10–10) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.67 (2–3) |
| L2 components implemented | 9.67 (9–10) |
| L2 components total | 12.67 (12–13) |
| end to end | 9.67 (9–10) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 9.67 (9–10) |
| L1 attempts per split spec | 1.67 (0.00–5.00) |
| minutes | 3.46 (3.35–3.56) |
| weak specs (satisfied by copies and constants) | 5.00 (5–5) |
| end to end, non-trivial spec | 4.67 (4–5) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 1.00 (1–1) |
| L2 implemented by the harness skeleton alone | 4.00 (4–4) |
| L2 implemented with the model | 5.67 (5–6) |
| L2 result fields written by the harness | 9.67 (9–10) |
| L2 result fields written by the model | 8.67 (8–9) |
| end to end, non-trivial spec, model wrote code | 2.67 (2–3) |
| repair loops stopped early (L1 + L2) | 2.33 (2–3) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 9.67 (9–10) |
| specs, requirement | 13.00 (13–13) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 2.33 (2–3) |
| unknown-field | 0.67 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (3): 3/registration/S1, 4/ease-of-use/R7, 4/ease-of-use/R9

## runs/0000 - cctns/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 13.00 (13–13) |
| L1 accepted | 13.00 (13–13) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 10.00 (10–10) |
| L1 single-fallback | 0.33 (0–1) |
| L1 not decomposable (identity split → single) | 2.67 (2–3) |
| L2 components implemented | 9.33 (9–10) |
| L2 components total | 13.00 (13–13) |
| end to end | 9.33 (9–10) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 9.33 (9–10) |
| L1 attempts per split spec | 1.67 (0.00–5.00) |
| minutes | 4.00 (3.61–4.61) |
| weak specs (satisfied by copies and constants) | 5.00 (5–5) |
| end to end, non-trivial spec | 4.33 (4–5) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 1.00 (1–1) |
| L2 implemented by the harness skeleton alone | 4.00 (4–4) |
| L2 implemented with the model | 5.33 (5–6) |
| L2 result fields written by the harness | 9.33 (9–10) |
| L2 result fields written by the model | 8.33 (8–9) |
| end to end, non-trivial spec, model wrote code | 2.33 (2–3) |
| repair loops stopped early (L1 + L2) | 2.33 (2–3) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 9.33 (9–10) |
| specs, requirement | 13.00 (13–13) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 2.33 (2–3) |
| unknown-field | 1.33 (1–2) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (3): 3/registration/S1, 4/ease-of-use/R7, 4/ease-of-use/R9

## runs/0000 - cctns/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 10.00 (10–10) |
| L1 accepted | 10.00 (10–10) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 9.00 (9–9) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 1.00 (1–1) |
| L2 components implemented | 6.00 (6–6) |
| L2 components total | 10.00 (10–10) |
| end to end | 6.00 (6–6) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 6.00 (6–6) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 5.67 (5.16–5.94) |
| weak specs (satisfied by copies and constants) | 4.00 (4–4) |
| end to end, non-trivial spec | 2.00 (2–2) |
| L2 implemented by the harness skeleton alone | 4.00 (4–4) |
| L2 implemented with the model | 2.00 (2–2) |
| L2 result fields written by the harness | 8.00 (8–8) |
| L2 result fields written by the model | 3.00 (3–3) |
| end to end, non-trivial spec, model wrote code | 0.00 (0–0) |
| repair loops stopped early (L1 + L2) | 1.00 (0–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 6.00 (6–6) |
| specs, requirement | 10.00 (10–10) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 3.00 (3–3) |
| unknown-field | 0.67 (0–1) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (4): 3/registration/S1, 4/audit-module/R5, 4/system-availability/R4, 5/S7

## runs/0000 - cctns/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 10.00 (10–10) |
| L1 accepted | 9.00 (9–9) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 9.00 (9–9) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
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
