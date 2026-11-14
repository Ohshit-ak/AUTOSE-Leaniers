## runs/2008 - keepass/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 19.00 (19–19) |
| L1 accepted | 19.00 (19–19) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 19.00 (19–19) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 16.00 (16–16) |
| L2 components total | 19.00 (19–19) |
| end to end | 16.00 (16–16) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 16.00 (16–16) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 4.60 (3.12–6.84) |
| weak specs (satisfied by copies and constants) | 12.00 (12–12) |
| end to end, non-trivial spec | 5.00 (5–5) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 1.00 (1–1) |
| L2 implemented by the harness skeleton alone | 10.00 (10–10) |
| L2 implemented with the model | 6.00 (6–6) |
| L2 result fields written by the harness | 26.00 (26–26) |
| L2 result fields written by the model | 8.00 (8–8) |
| end to end, non-trivial spec, model wrote code | 1.00 (1–1) |
| repair loops stopped early (L1 + L2) | 0.67 (0–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 16.00 (16–16) |
| specs, requirement | 19.00 (19–19) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| type-error | 1.67 (1–2) |
| po3 | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (3): 3.13.1/S1, 3.15.1/I3, 3.9.1/S3

## runs/2008 - keepass/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 19.00 (19–19) |
| L1 accepted | 19.00 (19–19) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 19.00 (19–19) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 15.67 (15–16) |
| L2 components total | 19.00 (19–19) |
| end to end | 15.67 (15–16) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 15.67 (15–16) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 3.84 (2.44–5.98) |
| weak specs (satisfied by copies and constants) | 12.00 (12–12) |
| end to end, non-trivial spec | 5.00 (5–5) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 0.67 (0–1) |
| L2 implemented by the harness skeleton alone | 10.00 (10–10) |
| L2 implemented with the model | 5.67 (5–6) |
| L2 result fields written by the harness | 26.00 (26–26) |
| L2 result fields written by the model | 7.33 (6–8) |
| end to end, non-trivial spec, model wrote code | 1.00 (1–1) |
| repair loops stopped early (L1 + L2) | 1.00 (1–1) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 15.67 (15–16) |
| specs, requirement | 19.00 (19–19) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 1.67 (1–2) |
| type-error | 1.00 (1–1) |
| syntax | 0.67 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (3): 3.13.1/S1, 3.15.1/I3, 3.9.1/S3

## runs/2008 - keepass/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 15.00 (15–15) |
| L1 chain (two components) | 1.00 (1–1) |
| L1 single (not split) | 12.00 (12–12) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.00 (2–2) |
| L2 components implemented | 13.33 (13–14) |
| L2 components total | 16.00 (16–16) |
| end to end | 12.33 (12–13) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 12.00 (12–12) |
| L1 attempts per split spec | 1.00 (1–1) |
| minutes | 3.52 (3.31–3.62) |
| weak specs (satisfied by copies and constants) | 9.00 (9–9) |
| end to end, non-trivial spec | 3.33 (3–4) |
| L2 implemented by the harness skeleton alone | 9.00 (9–9) |
| L2 implemented with the model | 4.33 (4–5) |
| L2 result fields written by the harness | 18.00 (18–18) |
| L2 result fields written by the model | 4.33 (4–5) |
| end to end, non-trivial spec, model wrote code | 0.33 (0–1) |
| repair loops stopped early (L1 + L2) | 1.00 (1–1) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 12.33 (12–13) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 1.33 (1–2) |
| type-error | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | 3.9.1/S3 | first (`ComputeFoundContract`) | syntax | — |
| rep3 | 3.9.1/S3 | first (`ComputeFoundContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.00 (1–1) |

Not end to end in every repetition (2): 3.13.1/S1, 3.3.1/S1

## runs/2008 - keepass/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 13.33 (13–14) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 12.00 (12–12) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
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
