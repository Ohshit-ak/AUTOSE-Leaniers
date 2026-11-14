## runs/2005 - phin/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 34.00 (34–34) |
| L1 accepted | 33.33 (33–34) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 31.00 (31–31) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 1.00 (1–1) |
| L2 components implemented | 26.00 (25–27) |
| L2 components total | 34.67 (34–36) |
| end to end | 24.67 (24–25) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 24.00 (24–24) |
| L1 attempts per split spec | 2.83 (2.50–3.50) |
| minutes | 7.06 (6.66–7.41) |
| weak specs (satisfied by copies and constants) | 11.00 (11–11) |
| end to end, non-trivial spec | 13.67 (13–14) |
| weak specs that only pass data through (copy-ok) | 3.00 (3–3) |
| end to end, copy-ok spec | 3.00 (3–3) |
| L2 implemented by the harness skeleton alone | 21.33 (21–22) |
| L2 implemented with the model | 4.67 (4–5) |
| L2 result fields written by the harness | 66.67 (66–68) |
| L2 result fields written by the model | 9.00 (8–10) |
| end to end, non-trivial spec, model wrote code | 1.67 (1–2) |
| repair loops stopped early (L1 + L2) | 3.33 (3–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 24.67 (24–25) |
| specs, requirement | 34.00 (34–34) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.33 (5–7) |
| syntax | 2.33 (2–3) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | 2.5.3/S1 | first (`ComputeMessageIDContract`) | po3 | — |
| rep3 | 2.5.3/S1 | first (`ComputeMessageIDContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (8): 1/S5, 2.2.6.1/S1, 2.2.6.2/S1, 2.2.6.6/S1, 2.3.1.1/S1, 2.3.3.3/S1, 2.5.7/S1, 2.5.9/S1

## runs/2005 - phin/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 34.00 (34–34) |
| L1 accepted | 34.00 (34–34) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 31.00 (31–31) |
| L1 single-fallback | 1.00 (1–1) |
| L1 not decomposable (identity split → single) | 0.67 (0–1) |
| L2 components implemented | 26.67 (26–27) |
| L2 components total | 35.33 (35–36) |
| end to end | 25.33 (25–26) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 25.00 (25–25) |
| L1 attempts per split spec | 2.89 (2.67–3.00) |
| minutes | 7.41 (6.90–7.77) |
| weak specs (satisfied by copies and constants) | 11.00 (11–11) |
| end to end, non-trivial spec | 14.33 (14–15) |
| weak specs that only pass data through (copy-ok) | 3.00 (3–3) |
| end to end, copy-ok spec | 3.00 (3–3) |
| L2 implemented by the harness skeleton alone | 21.00 (21–21) |
| L2 implemented with the model | 5.67 (5–6) |
| L2 result fields written by the harness | 66.33 (66–67) |
| L2 result fields written by the model | 10.67 (10–11) |
| end to end, non-trivial spec, model wrote code | 2.33 (2–3) |
| repair loops stopped early (L1 + L2) | 0.67 (0–1) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.17 (5.00–5.50) |
| end to end, requirement | 25.33 (25–26) |
| specs, requirement | 34.00 (34–34) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.67 (6–7) |
| syntax | 1.67 (1–2) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | 2.5.3/S1 | first (`ComputeMessageIDContract`) | po3 | — |
| rep3 | 2.5.3/S1 | first (`ComputeMessageIDContract`) | po3 | — |
| rep3 | 2.5.9/S1 | first (`ProcessCountermeasuresContract`) | type-error | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (8): 1/S5, 2.2.6.1/S1, 2.2.6.2/S1, 2.2.6.6/S1, 2.3.1.1/S1, 2.3.3.3/S1, 2.5.7/S1, 2.5.9/S1

## runs/2005 - phin/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 31.00 (31–31) |
| L1 accepted | 31.00 (31–31) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 28.00 (28–28) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 3.00 (3–3) |
| L2 components implemented | 16.00 (16–16) |
| L2 components total | 31.00 (31–31) |
| end to end | 16.00 (16–16) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 16.00 (16–16) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 9.19 (8.79–9.84) |
| weak specs (satisfied by copies and constants) | 13.00 (13–13) |
| end to end, non-trivial spec | 5.00 (5–5) |
| L2 implemented by the harness skeleton alone | 13.00 (13–13) |
| L2 implemented with the model | 3.00 (3–3) |
| L2 result fields written by the harness | 34.00 (34–34) |
| L2 result fields written by the model | 5.00 (5–5) |
| end to end, non-trivial spec, model wrote code | 1.00 (1–1) |
| repair loops stopped early (L1 + L2) | 3.00 (2–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 16.00 (16–16) |
| specs, requirement | 31.00 (31–31) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 14.00 (13–15) |
| unknown-field | 0.67 (0–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (15): 2.2.1.3/S1, 2.2.2.1/S1, 2.2.6.10/S1, 2.2.6.2/S1, 2.2.6.3/S1, 2.2.6.6/S1, 2.2.6.7/S1, 2.2.6.9/S1, 2.3.1.1/S1, 2.3.3.3/S1, 2.4.4/S1, 2.5.1/S1, 2.5.10/S1, 2.5.12/S1, 2.5.7/S1

## runs/2005 - phin/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 31.00 (31–31) |
| L1 accepted | 28.00 (28–28) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 28.00 (28–28) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
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
