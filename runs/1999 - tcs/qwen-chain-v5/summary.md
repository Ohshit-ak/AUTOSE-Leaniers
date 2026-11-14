## runs/1999 - tcs/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 46.00 (46–46) |
| L1 accepted | 42.67 (42–43) |
| L1 chain (two components) | 0.67 (0–1) |
| L1 single (not split) | 37.00 (37–37) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 5.00 (4–6) |
| L2 components implemented | 34.67 (33–36) |
| L2 components total | 43.33 (43–44) |
| end to end | 34.00 (32–35) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 33.67 (32–35) |
| L1 attempts per split spec | 4.17 (3.50–5.00) |
| minutes | 15.97 (14.68–16.67) |
| weak specs (satisfied by copies and constants) | 15.00 (15–15) |
| end to end, non-trivial spec | 19.00 (17–20) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 19.67 (19–20) |
| L2 implemented with the model | 15.00 (13–16) |
| L2 result fields written by the harness | 83.00 (81–85) |
| L2 result fields written by the model | 41.33 (37–44) |
| end to end, non-trivial spec, model wrote code | 8.00 (6–9) |
| repair loops stopped early (L1 + L2) | 5.33 (4–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 3.33 (0–5) |
| end to end, requirement | 34.00 (32–35) |
| specs, requirement | 46.00 (46–46) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 2.67 (2–4) |
| syntax | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 8.00 (7–10) |
| unknown-name | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 3.2.1/S6 | second (`GenerateOutputContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.67 (0–1) |

Not end to end in every repetition (10): 3.1.1/S2, 3.11.3/S1, 3.14/S3, 3.2.2.1/S1, 3.2.2.2.1/S1, 3.2.2.2/S1, 3.2.3.1/S4, 3.2.3.2/S1, 3.3.1.6/S2, 3.8.1/S1

## runs/1999 - tcs/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 46.00 (46–46) |
| L1 accepted | 46.00 (46–46) |
| L1 chain (two components) | 0.67 (0–1) |
| L1 single (not split) | 37.00 (37–37) |
| L1 single-fallback | 3.00 (2–4) |
| L1 not decomposable (identity split → single) | 5.33 (5–6) |
| L2 components implemented | 36.67 (36–37) |
| L2 components total | 46.67 (46–47) |
| end to end | 36.33 (36–37) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 36.00 (35–37) |
| L1 attempts per split spec | 4.33 (4.00–4.75) |
| minutes | 16.48 (15.37–18.32) |
| weak specs (satisfied by copies and constants) | 15.00 (15–15) |
| end to end, non-trivial spec | 21.33 (21–22) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 19.33 (19–20) |
| L2 implemented with the model | 17.33 (17–18) |
| L2 result fields written by the harness | 87.00 (84–93) |
| L2 result fields written by the model | 46.00 (44–48) |
| end to end, non-trivial spec, model wrote code | 10.33 (10–11) |
| repair loops stopped early (L1 + L2) | 4.33 (3–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 3.67 (0–6) |
| end to end, requirement | 36.33 (36–37) |
| specs, requirement | 46.00 (46–46) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 2.33 (1–4) |
| type-error (fell back to single) | 0.33 (0–1) |
| syntax (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 8.67 (8–9) |
| unknown-name | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.67 (0–1) |

Not end to end in every repetition (7): 3.11.3/S1, 3.14/S3, 3.2.2.2.1/S1, 3.2.2.2/S1, 3.2.3.2/S1, 3.3.1.6/S2, 3.8.1/S1

## runs/1999 - tcs/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 43.00 (43–43) |
| L1 accepted | 42.00 (41–43) |
| L1 chain (two components) | 0.67 (0–1) |
| L1 single (not split) | 39.00 (39–39) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.33 (2–3) |
| L2 components implemented | 35.67 (35–37) |
| L2 components total | 42.67 (41–44) |
| end to end | 35.33 (35–36) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 35.33 (35–36) |
| L1 attempts per split spec | 3.83 (3.00–4.50) |
| minutes | 16.30 (15.50–17.15) |
| weak specs (satisfied by copies and constants) | 20.00 (20–20) |
| end to end, non-trivial spec | 17.33 (17–18) |
| L2 implemented by the harness skeleton alone | 18.00 (18–18) |
| L2 implemented with the model | 17.67 (17–19) |
| L2 result fields written by the harness | 66.00 (65–68) |
| L2 result fields written by the model | 42.33 (41–45) |
| end to end, non-trivial spec, model wrote code | 7.33 (7–8) |
| repair loops stopped early (L1 + L2) | 2.67 (2–3) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 3.33 (0–5) |
| end to end, requirement | 35.33 (35–36) |
| specs, requirement | 43.00 (43–43) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| unknown-field | 0.67 (0–1) |
| po2 | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 5.00 (4–6) |
| unknown-name | 0.67 (0–1) |
| unknown-field | 0.67 (0–1) |
| type-error | 0.33 (0–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | 3.2.1/S6 | second (`ComputeOutputFromDiscrepanciesContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.67 (0–1) |

Not end to end in every repetition (7): 3.2.1.1.1/S2, 3.2.1/S6, 3.2.2.1.1.1/S1, 3.2.2.2.1/S1, 3.2.2.3.1/S1, 3.2.5.2.1/S5, 3.8.1/S1

## runs/1999 - tcs/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 43.00 (43–43) |
| L1 accepted | 39.00 (39–39) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 39.00 (39–39) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
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
