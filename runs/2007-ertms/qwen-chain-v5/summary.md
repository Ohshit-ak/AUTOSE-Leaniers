## runs/2007-ertms/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 36.00 (36–36) |
| L1 accepted | 35.67 (35–36) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 33.00 (33–33) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.67 (2–3) |
| L2 components implemented | 28.33 (28–29) |
| L2 components total | 35.67 (35–36) |
| end to end | 28.33 (28–29) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 28.33 (28–29) |
| L1 attempts per split spec | 1.00 (0.00–3.00) |
| minutes | 6.79 (6.00–7.73) |
| weak specs (satisfied by copies and constants) | 23.00 (23–23) |
| end to end, non-trivial spec | 6.33 (6–7) |
| weak specs that only pass data through (copy-ok) | 3.00 (3–3) |
| end to end, copy-ok spec | 3.00 (3–3) |
| L2 implemented by the harness skeleton alone | 23.00 (23–23) |
| L2 implemented with the model | 5.33 (5–6) |
| L2 result fields written by the harness | 38.67 (38–39) |
| L2 result fields written by the model | 7.00 (6–8) |
| end to end, non-trivial spec, model wrote code | 3.33 (3–4) |
| repair loops stopped early (L1 + L2) | 4.67 (4–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 28.33 (28–29) |
| specs, requirement | 36.00 (36–36) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.67 (6–8) |
| unknown-field | 0.67 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (7): 4.1.1.3a#2, 4.1.2.14b, 4.1.5.1b, 4.1.5.5, 4.3.10.7, 4.3.3.2d, 4.3.3.3

## runs/2007-ertms/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 36.00 (36–36) |
| L1 accepted | 36.00 (36–36) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 33.00 (33–33) |
| L1 single-fallback | 0.67 (0–1) |
| L1 not decomposable (identity split → single) | 2.33 (2–3) |
| L2 components implemented | 29.00 (29–29) |
| L2 components total | 36.00 (36–36) |
| end to end | 29.00 (29–29) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 29.00 (29–29) |
| L1 attempts per split spec | 2.67 (0.00–5.00) |
| minutes | 13.37 (8.76–17.42) |
| weak specs (satisfied by copies and constants) | 23.00 (23–23) |
| end to end, non-trivial spec | 7.00 (7–7) |
| weak specs that only pass data through (copy-ok) | 3.00 (3–3) |
| end to end, copy-ok spec | 3.00 (3–3) |
| L2 implemented by the harness skeleton alone | 23.00 (23–23) |
| L2 implemented with the model | 6.00 (6–6) |
| L2 result fields written by the harness | 39.00 (39–39) |
| L2 result fields written by the model | 8.00 (8–8) |
| end to end, non-trivial spec, model wrote code | 4.00 (4–4) |
| repair loops stopped early (L1 + L2) | 4.33 (4–5) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 29.00 (29–29) |
| specs, requirement | 36.00 (36–36) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.00 (6–6) |
| unknown-field | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (7): 4.1.1.3a#2, 4.1.2.14b, 4.1.5.1b, 4.1.5.5, 4.3.10.7, 4.3.3.2d, 4.3.3.3

## runs/2007-ertms/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 36.00 (36–36) |
| L1 accepted | 36.00 (36–36) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 36.00 (36–36) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 33.00 (33–33) |
| L2 components total | 36.00 (36–36) |
| end to end | 33.00 (33–33) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 33.00 (33–33) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 8.00 (5.12–11.34) |
| weak specs (satisfied by copies and constants) | 27.00 (27–27) |
| end to end, non-trivial spec | 6.00 (6–6) |
| L2 implemented by the harness skeleton alone | 27.00 (27–27) |
| L2 implemented with the model | 6.00 (6–6) |
| L2 result fields written by the harness | 40.00 (40–40) |
| L2 result fields written by the model | 10.00 (10–10) |
| end to end, non-trivial spec, model wrote code | 3.00 (3–3) |
| repair loops stopped early (L1 + L2) | 1.67 (1–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 33.00 (33–33) |
| specs, requirement | 36.00 (36–36) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 2.33 (2–3) |
| unknown-name | 0.67 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (3): 4.1.1.4a, 4.1.5.5, 4.3.3.3

## runs/2007-ertms/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 36.00 (36–36) |
| L1 accepted | 36.00 (36–36) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 36.00 (36–36) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 31.00 (31–31) |
| L2 components total | 36.00 (36–36) |
| end to end | 31.00 (31–31) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 31.00 (31–31) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 4.60 (4.55–4.66) |
| weak specs (satisfied by copies and constants) | 27.00 (27–27) |
| end to end, non-trivial spec | 6.00 (6–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 31.00 (31–31) |
| specs, requirement | 36.00 (36–36) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 4.33 (4–5) |
| unknown-name | 0.67 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (5): 4.1.1.4a, 4.1.3.4b, 4.1.5.5, 4.3.3.3, 4.5.2.5b
