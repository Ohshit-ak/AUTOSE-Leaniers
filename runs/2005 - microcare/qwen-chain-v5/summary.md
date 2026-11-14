## runs/2005 - microcare/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 24.00 (24–24) |
| L1 accepted | 23.33 (22–24) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 21.00 (21–21) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.67 (0–1) |
| L2 components implemented | 17.00 (16–18) |
| L2 components total | 25.00 (23–26) |
| end to end | 15.67 (15–16) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 15.00 (14–16) |
| L1 attempts per split spec | 3.50 (3.00–4.00) |
| minutes | 14.24 (10.81–20.61) |
| weak specs (satisfied by copies and constants) | 10.00 (10–10) |
| end to end, non-trivial spec | 7.67 (7–8) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 10.67 (10–12) |
| L2 implemented with the model | 6.33 (5–8) |
| L2 result fields written by the harness | 27.33 (24–30) |
| L2 result fields written by the model | 7.33 (6–9) |
| end to end, non-trivial spec, model wrote code | 4.33 (3–5) |
| repair loops stopped early (L1 + L2) | 2.67 (2–3) |
| L1 chain with a repaired second `pre` | 0.67 (0–1) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 15.67 (15–16) |
| specs, requirement | 24.00 (24–24) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.67 (0–2) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.33 (7–8) |
| unknown-name | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | Design Constraints/S2#6 | second (`FinalizeContract`) | po3 | — |
| rep3 | Design Constraints/S2#6 | second (`DecideOutcomeContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (7): 1./S2, 2.1.1/I11, 2.1.1/I9, 3./S2, Design Constraints/I17, Design Constraints/S2#6, Design Constraints/S5

## runs/2005 - microcare/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 24.00 (24–24) |
| L1 accepted | 24.00 (24–24) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 21.00 (21–21) |
| L1 single-fallback | 0.67 (0–2) |
| L1 not decomposable (identity split → single) | 0.67 (0–1) |
| L2 components implemented | 18.00 (17–19) |
| L2 components total | 25.67 (25–26) |
| end to end | 16.67 (15–18) |
| end to end, chain | 1.00 (0–2) |
| end to end, single | 15.67 (14–18) |
| L1 attempts per split spec | 3.17 (2.00–4.00) |
| minutes | 15.39 (10.35–22.39) |
| weak specs (satisfied by copies and constants) | 10.00 (10–10) |
| end to end, non-trivial spec | 8.67 (7–10) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 10.67 (10–12) |
| L2 implemented with the model | 7.33 (5–9) |
| L2 result fields written by the harness | 27.33 (26–30) |
| L2 result fields written by the model | 8.67 (6–11) |
| end to end, non-trivial spec, model wrote code | 5.33 (3–7) |
| repair loops stopped early (L1 + L2) | 3.00 (2–4) |
| L1 chain with a repaired second `pre` | 0.33 (0–1) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 16.67 (15–18) |
| specs, requirement | 24.00 (24–24) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 0.67 (0–2) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.00 (6–8) |
| unknown-name | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | Design Constraints/S2#6 | second (`FinalizeContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (6): 1./S2, 2.1.1/I11, 2.1.1/I9, 3./S2, Design Constraints/I17, Design Constraints/S5

## runs/2005 - microcare/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 21.00 (21–21) |
| L1 accepted | 21.00 (21–21) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 19.00 (19–19) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.00 (2–2) |
| L2 components implemented | 13.33 (13–14) |
| L2 components total | 21.00 (21–21) |
| end to end | 13.33 (13–14) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 13.33 (13–14) |
| L1 attempts per split spec | 0.00 (0.00–0.00) |
| minutes | 7.72 (6.74–9.49) |
| weak specs (satisfied by copies and constants) | 10.00 (10–10) |
| end to end, non-trivial spec | 6.00 (6–6) |
| L2 implemented by the harness skeleton alone | 9.00 (9–9) |
| L2 implemented with the model | 4.33 (4–5) |
| L2 result fields written by the harness | 15.00 (15–15) |
| L2 result fields written by the model | 8.67 (8–10) |
| end to end, non-trivial spec, model wrote code | 3.00 (3–3) |
| repair loops stopped early (L1 + L2) | 2.67 (2–3) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 13.33 (13–14) |
| specs, requirement | 21.00 (21–21) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.67 (6–7) |
| syntax | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (7): 1./S2, 3./I5, Design Constraints/I2, Design Constraints/S15, Design Constraints/S3#4, i/S2, iii/I5

## runs/2005 - microcare/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 21.00 (21–21) |
| L1 accepted | 19.00 (19–19) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 19.00 (19–19) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
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
