## runs/1995 - gemini/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 37.00 (37–37) |
| L1 accepted | 35.00 (34–36) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 30.00 (30–30) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 3.33 (3–4) |
| L2 components implemented | 29.00 (27–30) |
| L2 components total | 36.67 (35–38) |
| end to end | 27.33 (26–28) |
| end to end, chain | 1.33 (1–2) |
| end to end, single | 26.00 (25–27) |
| L1 attempts per split spec | 2.78 (2.33–3.25) |
| minutes | 10.15 (9.60–11.12) |
| weak specs (satisfied by copies and constants) | 19.00 (19–19) |
| end to end, non-trivial spec | 10.67 (10–11) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 1.00 (1–1) |
| L2 implemented by the harness skeleton alone | 20.33 (20–21) |
| L2 implemented with the model | 8.67 (7–10) |
| L2 result fields written by the harness | 42.67 (42–43) |
| L2 result fields written by the model | 17.00 (14–19) |
| end to end, non-trivial spec, model wrote code | 0.67 (0–1) |
| repair loops stopped early (L1 + L2) | 4.00 (3–5) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 27.33 (26–28) |
| specs, requirement | 37.00 (37–37) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.67 (1–2) |
| type-error | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.33 (7–8) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | 4.2.4.2/I3 | second (`FinalizeContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (8): 2.10/S4, 2.7.1/S6, 3.2.3/S1, 3.2.5/S6, 3.3.1/S6, 4.2.2.1/S3, 4.2.4.2/I3, 4.3.1.2.1/I4

## runs/1995 - gemini/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 37.00 (37–37) |
| L1 accepted | 37.00 (37–37) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 30.00 (30–30) |
| L1 single-fallback | 2.33 (2–3) |
| L1 not decomposable (identity split → single) | 3.00 (3–3) |
| L2 components implemented | 31.00 (30–32) |
| L2 components total | 38.67 (38–39) |
| end to end | 29.33 (29–30) |
| end to end, chain | 1.33 (1–2) |
| end to end, single | 28.00 (28–28) |
| L1 attempts per split spec | 3.25 (3.00–3.50) |
| minutes | 13.06 (11.86–14.61) |
| weak specs (satisfied by copies and constants) | 19.00 (19–19) |
| end to end, non-trivial spec | 12.00 (12–12) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 1.00 (1–1) |
| L2 implemented by the harness skeleton alone | 20.33 (20–21) |
| L2 implemented with the model | 10.67 (10–11) |
| L2 result fields written by the harness | 44.33 (44–45) |
| L2 result fields written by the model | 20.00 (19–21) |
| end to end, non-trivial spec, model wrote code | 2.00 (2–2) |
| repair loops stopped early (L1 + L2) | 1.67 (1–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 29.33 (29–30) |
| specs, requirement | 37.00 (37–37) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 2.33 (2–3) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.33 (7–8) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | 4.2.4.2/I3 | second (`FinalizeContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (7): 2.10/S4, 2.7.1/S6, 3.2.3/S1, 3.2.5/S6, 3.3.1/S6, 4.2.2.1/S3, 4.3.1.2.1/I4

## runs/1995 - gemini/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 37.00 (37–37) |
| L1 accepted | 36.33 (36–37) |
| L1 chain (two components) | 1.00 (1–1) |
| L1 single (not split) | 33.00 (33–33) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.33 (2–3) |
| L2 components implemented | 29.67 (29–30) |
| L2 components total | 37.33 (37–38) |
| end to end | 29.00 (29–29) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 28.33 (28–29) |
| L1 attempts per split spec | 2.50 (2.00–3.00) |
| minutes | 7.23 (6.31–8.20) |
| weak specs (satisfied by copies and constants) | 21.00 (21–21) |
| end to end, non-trivial spec | 11.00 (11–11) |
| L2 implemented by the harness skeleton alone | 23.00 (22–24) |
| L2 implemented with the model | 6.67 (6–7) |
| L2 result fields written by the harness | 38.00 (37–39) |
| L2 result fields written by the model | 13.67 (13–14) |
| end to end, non-trivial spec, model wrote code | 2.67 (2–3) |
| repair loops stopped early (L1 + L2) | 3.33 (2–5) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 29.00 (29–29) |
| specs, requirement | 37.00 (37–37) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.67 (6–8) |
| type-error | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.00 (1–1) |

Not end to end in every repetition (8): 2.6.3/I6, 3.2.5/S6, 3.3.4.1/I1, 3.4.1/S8, 4.2.4.1/I6, 4.2.4.2/I3, 4.3.1.2.1/I1, 4.3.1.2.2/S5

## runs/1995 - gemini/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 37.00 (37–37) |
| L1 accepted | 34.33 (34–35) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 33.00 (33–33) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 27.33 (26–28) |
| L2 components total | 35.67 (35–37) |
| end to end | 26.00 (25–27) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 25.33 (25–26) |
| L1 attempts per split spec | 3.83 (3.50–4.00) |
| minutes | 7.29 (7.12–7.59) |
| weak specs (satisfied by copies and constants) | 21.00 (21–21) |
| end to end, non-trivial spec | 8.67 (8–9) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 26.00 (25–27) |
| specs, requirement | 37.00 (37–37) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 1.33 (1–2) |
| visibility | 0.67 (0–2) |
| po2 | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.67 (6–9) |
| unknown-name | 0.33 (0–1) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 2.6.3/S17 | second (`ComputeFeeContract`) | po3 | — |
| rep2 | 4.2.4.2/I3 | second (`ComputeOutputContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (10): 2.10/S4, 2.6.3/I6, 3.2.5/S6, 3.4.1/S8, 3.5.6.2/I5, 4.2.4.1/I6, 4.2.4.2/I3, 4.2.4.2/I4, 4.3.1.2.1/I1, 4.3.1.2.2/S5
