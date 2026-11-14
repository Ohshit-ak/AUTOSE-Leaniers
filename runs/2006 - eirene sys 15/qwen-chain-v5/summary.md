## runs/2006 - eirene sys 15/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 58.00 (58–58) |
| L1 accepted | 54.67 (54–55) |
| L1 chain (two components) | 4.00 (4–4) |
| L1 single (not split) | 47.00 (47–47) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 3.67 (3–4) |
| L2 components implemented | 49.33 (48–50) |
| L2 components total | 58.67 (58–59) |
| end to end | 45.33 (44–46) |
| end to end, chain | 3.67 (3–4) |
| end to end, single | 41.67 (40–43) |
| L1 attempts per split spec | 2.94 (2.57–3.25) |
| minutes | 11.30 (11.01–11.47) |
| weak specs (satisfied by copies and constants) | 25.00 (25–25) |
| end to end, non-trivial spec | 24.00 (23–25) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 37.33 (37–38) |
| L2 implemented with the model | 12.00 (10–13) |
| L2 result fields written by the harness | 55.67 (55–56) |
| L2 result fields written by the model | 16.33 (13–18) |
| end to end, non-trivial spec, model wrote code | 7.00 (6–8) |
| repair loops stopped early (L1 + L2) | 4.67 (4–6) |
| L1 chain with a repaired second `pre` | 0.33 (0–1) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 45.33 (44–46) |
| specs, requirement | 58.00 (58–58) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| visibility | 2.00 (2–2) |
| po2 | 0.67 (0–1) |
| unknown-field | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 6.67 (6–8) |
| unknown-field | 1.33 (0–2) |
| syntax | 1.00 (0–2) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep3 | 7.3.3/S1 | second (`ShowMessageContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 4.00 (4–4) |

Not end to end in every repetition (11): 10.5.1/S1, 13.5.8/S1, 3.7.3/S1, 4.5.36/S1, 4.5.9/S1, 5.4.9/S1, 5.6.1/S1, 5.6.3/S1, 8.2.3/S1, 9.2.1/S1, 9.2.6/S1

## runs/2006 - eirene sys 15/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 58.00 (58–58) |
| L1 accepted | 58.00 (58–58) |
| L1 chain (two components) | 3.67 (3–4) |
| L1 single (not split) | 47.00 (47–47) |
| L1 single-fallback | 2.67 (2–3) |
| L1 not decomposable (identity split → single) | 4.67 (4–5) |
| L2 components implemented | 52.00 (51–53) |
| L2 components total | 61.67 (61–62) |
| end to end | 48.33 (48–49) |
| end to end, chain | 3.67 (3–4) |
| end to end, single | 44.67 (44–45) |
| L1 attempts per split spec | 2.85 (2.71–3.00) |
| minutes | 11.76 (11.43–12.01) |
| weak specs (satisfied by copies and constants) | 25.00 (25–25) |
| end to end, non-trivial spec | 24.33 (24–25) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 37.33 (37–38) |
| L2 implemented with the model | 14.67 (14–15) |
| L2 result fields written by the harness | 57.00 (57–57) |
| L2 result fields written by the model | 23.33 (21–25) |
| end to end, non-trivial spec, model wrote code | 7.33 (7–8) |
| repair loops stopped early (L1 + L2) | 3.33 (2–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 48.33 (48–49) |
| specs, requirement | 58.00 (58–58) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| visibility (fell back to single) | 2.00 (2–2) |
| unknown-field (fell back to single) | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 8.33 (7–9) |
| syntax | 0.67 (0–1) |
| type-error | 0.33 (0–1) |
| unknown-field | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.67 (3–4) |

Not end to end in every repetition (9): 10.5.1/S1, 13.5.8/S1, 4.5.36/S1, 4.5.9/S1, 5.4.9/S1, 5.6.1/S1, 5.6.3/S1, 9.2.1/S1, 9.2.6/S1

## runs/2006 - eirene sys 15/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 55.00 (55–55) |
| L1 accepted | 54.00 (54–54) |
| L1 chain (two components) | 3.33 (3–4) |
| L1 single (not split) | 45.00 (45–45) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 5.67 (5–6) |
| L2 components implemented | 44.67 (43–46) |
| L2 components total | 57.33 (57–58) |
| end to end | 42.67 (42–43) |
| end to end, chain | 1.67 (1–2) |
| end to end, single | 41.00 (41–41) |
| L1 attempts per split spec | 1.55 (1.40–1.75) |
| minutes | 13.88 (13.18–14.74) |
| weak specs (satisfied by copies and constants) | 22.00 (22–22) |
| end to end, non-trivial spec | 21.67 (21–22) |
| L2 implemented by the harness skeleton alone | 29.33 (29–30) |
| L2 implemented with the model | 15.33 (14–16) |
| L2 result fields written by the harness | 45.33 (44–47) |
| L2 result fields written by the model | 23.00 (21–24) |
| end to end, non-trivial spec, model wrote code | 7.67 (7–8) |
| repair loops stopped early (L1 + L2) | 7.00 (6–9) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 42.67 (42–43) |
| specs, requirement | 55.00 (55–55) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| unknown-field | 0.67 (0–1) |
| po2 | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 12.33 (12–13) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 5.3.12/S1 | first (`AddMessageContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.33 (3–4) |

Not end to end in every repetition (11): 13.3.2/S1, 14.4.3/S1, 4.5.36/S1, 4.5.9/S1, 5.3.12/S1, 5.5.2/S1, 5.7.9/S1, 8.3.2/S1, 9.2.1/S1, 9.2.3/S1, 9.2.6/S1

## runs/2006 - eirene sys 15/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 55.00 (55–55) |
| L1 accepted | 48.00 (48–48) |
| L1 chain (two components) | 3.00 (3–3) |
| L1 single (not split) | 45.00 (45–45) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 38.33 (38–39) |
| L2 components total | 51.00 (51–51) |
| end to end | 36.33 (36–37) |
| end to end, chain | 1.00 (1–1) |
| end to end, single | 35.33 (35–36) |
| L1 attempts per split spec | 4.10 (3.90–4.20) |
| minutes | 14.67 (13.78–16.33) |
| weak specs (satisfied by copies and constants) | 22.00 (22–22) |
| end to end, non-trivial spec | 19.33 (19–20) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.11 (5.00–5.33) |
| end to end, requirement | 36.33 (36–37) |
| specs, requirement | 55.00 (55–55) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 4.00 (4–4) |
| po2 | 2.00 (2–2) |
| unknown-field | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 12.00 (12–12) |
| type-error | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 5.3.12/S1 | first (`AddMessageContract`) | po3 | — |
| rep2 | 5.3.12/S1 | first (`ComputeNewMessageContract`) | po3 | — |
| rep3 | 5.3.12/S1 | first (`AddMessageContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.00 (3–3) |

Not end to end in every repetition (18): 11.3.15/S1, 13.3.2/S1, 14.2.4/S1, 4.3.5/S1, 4.5.36/S1, 4.5.9/S1, 5.3.12/S1, 5.4.9/S1, 5.5.2/S1, 5.5.24/S1, 5.6.3/S1, 5.6.4i/S1, 5.7.9/S1, 7.3.3/S1, 8.3.2/S1, 9.2.1/S1, 9.2.3/S1, 9.2.6/S1
