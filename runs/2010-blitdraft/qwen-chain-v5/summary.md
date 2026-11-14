## runs/2010-blitdraft/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 7.00 (7–7) |
| L1 accepted | 6.67 (6–7) |
| L1 chain (two components) | 0.33 (0–1) |
| L1 single (not split) | 6.00 (6–6) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.33 (0–1) |
| L2 components implemented | 6.00 (5–7) |
| L2 components total | 7.00 (6–8) |
| end to end | 5.67 (5–6) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 5.33 (5–6) |
| L1 attempts per split spec | 2.33 (0.00–4.00) |
| minutes | 1.26 (1.05–1.43) |
| weak specs (satisfied by copies and constants) | 3.00 (3–3) |
| end to end, non-trivial spec | 2.67 (2–3) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 4.33 (4–5) |
| L2 implemented with the model | 1.67 (1–2) |
| L2 result fields written by the harness | 10.33 (9–12) |
| L2 result fields written by the model | 2.67 (2–3) |
| end to end, non-trivial spec, model wrote code | 1.67 (1–2) |
| repair loops stopped early (L1 + L2) | 1.33 (1–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 5.67 (5–6) |
| specs, requirement | 7.00 (7–7) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.33 (0–1) |

Not end to end in every repetition (1): 2.1.1.2.1.11/S1

## runs/2010-blitdraft/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 7.00 (7–7) |
| L1 accepted | 7.00 (7–7) |
| L1 chain (two components) | 0.33 (0–1) |
| L1 single (not split) | 6.00 (6–6) |
| L1 single-fallback | 0.33 (0–1) |
| L1 not decomposable (identity split → single) | 0.33 (0–1) |
| L2 components implemented | 6.33 (6–7) |
| L2 components total | 7.33 (7–8) |
| end to end | 6.00 (6–6) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 5.67 (5–6) |
| L1 attempts per split spec | 2.33 (0.00–4.00) |
| minutes | 2.03 (1.57–2.49) |
| weak specs (satisfied by copies and constants) | 3.00 (3–3) |
| end to end, non-trivial spec | 3.00 (3–3) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 4.33 (4–5) |
| L2 implemented with the model | 2.00 (2–2) |
| L2 result fields written by the harness | 10.67 (10–12) |
| L2 result fields written by the model | 3.00 (3–3) |
| end to end, non-trivial spec, model wrote code | 2.00 (2–2) |
| repair loops stopped early (L1 + L2) | 1.00 (1–1) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 6.00 (6–6) |
| specs, requirement | 7.00 (7–7) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.33 (0–1) |

Not end to end in every repetition (1): 2.1.1.2.1.11/S1

## runs/2010-blitdraft/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 7.00 (7–7) |
| L1 accepted | 7.00 (7–7) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 7.00 (7–7) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 6.00 (6–6) |
| L2 components total | 7.00 (7–7) |
| end to end | 6.00 (6–6) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 6.00 (6–6) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 0.75 (0.71–0.77) |
| weak specs (satisfied by copies and constants) | 4.00 (4–4) |
| end to end, non-trivial spec | 2.00 (2–2) |
| L2 implemented by the harness skeleton alone | 5.00 (5–5) |
| L2 implemented with the model | 1.00 (1–1) |
| L2 result fields written by the harness | 8.00 (8–8) |
| L2 result fields written by the model | 2.00 (2–2) |
| end to end, non-trivial spec, model wrote code | 1.00 (1–1) |
| repair loops stopped early (L1 + L2) | 1.00 (1–1) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 6.00 (6–6) |
| specs, requirement | 7.00 (7–7) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (1): 2.1.1.2.1.11/S1

## runs/2010-blitdraft/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 7.00 (7–7) |
| L1 accepted | 7.00 (7–7) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 7.00 (7–7) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 6.00 (6–6) |
| L2 components total | 7.00 (7–7) |
| end to end | 6.00 (6–6) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 6.00 (6–6) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 1.12 (1.09–1.16) |
| weak specs (satisfied by copies and constants) | 4.00 (4–4) |
| end to end, non-trivial spec | 2.00 (2–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 6.00 (6–6) |
| specs, requirement | 7.00 (7–7) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (1): 2.1.1.2.1.11/S1
