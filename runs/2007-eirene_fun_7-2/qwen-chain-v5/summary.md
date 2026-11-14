## runs/2007-eirene_fun_7-2/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 92.00 (92–92) |
| L1 accepted | 91.33 (90–92) |
| L1 chain (two components) | 2.33 (1–3) |
| L1 single (not split) | 75.00 (75–75) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 14.00 (12–16) |
| L2 components implemented | 72.00 (71–74) |
| L2 components total | 93.67 (93–95) |
| end to end | 70.00 (68–72) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 70.00 (68–72) |
| L1 attempts per split spec | 2.64 (2.00–3.60) |
| minutes | 24.66 (24.34–25.03) |
| weak specs (satisfied by copies and constants) | 31.00 (31–31) |
| end to end, non-trivial spec | 41.00 (39–43) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 42.67 (42–43) |
| L2 implemented with the model | 29.33 (28–31) |
| L2 result fields written by the harness | 88.67 (85–92) |
| L2 result fields written by the model | 46.67 (46–48) |
| end to end, non-trivial spec, model wrote code | 17.00 (15–19) |
| repair loops stopped early (L1 + L2) | 10.33 (9–11) |
| L1 chain with a repaired second `pre` | 0.33 (0–1) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 70.00 (68–72) |
| specs, requirement | 92.00 (92–92) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| unknown-field | 0.33 (0–1) |
| po2 | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 20.33 (19–21) |
| unknown-field | 1.00 (1–1) |
| type-error | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 5.2.3.32 | second (`FinalizeContract`) | po3 | — |
| rep2 | 3.5.1 | first (`ComputeParticipantsContract`) | po3 | — |
| rep2 | 5.2.3.32 | second (`FinalizeContract`) | po3 | — |
| rep3 | 3.5.1 | first (`ComputeParticipantsContract`) | po3 | — |
| rep3 | 4.1.2 | second (`FormatOutputContract`) | po3 | — |
| rep3 | 5.2.3.32 | second (`FinalizeContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 2.33 (1–3) |

Not end to end in every repetition (19): 10.2.1, 12.2.1, 12.2.3, 13.1.6, 14.2.8, 2.3.12, 3.5.1, 5.2.2.37, 5.2.2.60, 5.2.2.61, 5.2.3.25ix, 5.2.3.26, 5.2.3.32, 5.2.3.40, 5.2.3.9, 5.2.4.4, 7.2.2.2, 7.2.2.3, 7.2.3.9i

## runs/2007-eirene_fun_7-2/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 92.00 (92–92) |
| L1 accepted | 92.00 (92–92) |
| L1 chain (two components) | 2.00 (1–3) |
| L1 single (not split) | 75.00 (75–75) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 15.00 (14–16) |
| L2 components implemented | 73.00 (72–74) |
| L2 components total | 94.00 (93–95) |
| end to end | 71.33 (70–73) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 71.33 (70–73) |
| L1 attempts per split spec | 2.28 (2.00–2.50) |
| minutes | 23.44 (22.00–25.59) |
| weak specs (satisfied by copies and constants) | 31.00 (31–31) |
| end to end, non-trivial spec | 42.33 (41–44) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 42.33 (42–43) |
| L2 implemented with the model | 30.67 (30–32) |
| L2 result fields written by the harness | 89.67 (88–92) |
| L2 result fields written by the model | 49.00 (46–53) |
| end to end, non-trivial spec, model wrote code | 18.33 (17–20) |
| repair loops stopped early (L1 + L2) | 10.33 (9–11) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 71.33 (70–73) |
| specs, requirement | 92.00 (92–92) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 19.33 (17–21) |
| unknown-field | 1.00 (1–1) |
| type-error | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 3.5.1 | first (`ComputeParticipantsContract`) | po3 | — |
| rep2 | 3.5.1 | first (`ComputeParticipantsContract`) | po3 | — |
| rep2 | 5.2.3.32 | second (`FinalizeContract`) | po3 | — |
| rep3 | 4.1.2 | second (`FormatOutputContract`) | po3 | — |
| rep3 | 5.2.3.32 | second (`FinalizeOutputContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 2.00 (1–3) |

Not end to end in every repetition (18): 10.2.1, 12.2.1, 12.2.3, 13.1.6, 14.2.8, 2.3.12, 3.5.1, 5.2.2.37, 5.2.2.60, 5.2.2.61, 5.2.3.25ix, 5.2.3.26, 5.2.3.40, 5.2.3.9, 5.2.4.4, 7.2.2.2, 7.2.2.3, 7.2.3.9i

## runs/2007-eirene_fun_7-2/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 82.00 (82–82) |
| L1 accepted | 82.00 (82–82) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 72.00 (72–72) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 8.33 (8–9) |
| L2 components implemented | 63.33 (63–64) |
| L2 components total | 83.67 (83–84) |
| end to end | 62.67 (62–63) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 62.33 (62–63) |
| L1 attempts per split spec | 1.83 (1.50–2.00) |
| minutes | 20.58 (19.15–21.82) |
| weak specs (satisfied by copies and constants) | 35.00 (35–35) |
| end to end, non-trivial spec | 30.67 (30–31) |
| L2 implemented by the harness skeleton alone | 38.00 (38–38) |
| L2 implemented with the model | 25.33 (25–26) |
| L2 result fields written by the harness | 75.33 (74–76) |
| L2 result fields written by the model | 35.67 (35–36) |
| end to end, non-trivial spec, model wrote code | 13.67 (13–14) |
| repair loops stopped early (L1 + L2) | 7.67 (6–9) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 62.67 (62–63) |
| specs, requirement | 82.00 (82–82) |

### L1 failures by class

none

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 19.67 (19–20) |
| type-error | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep3 | 5.2.3.25ix | second (`HandleAttemptsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (19): 11.2.1.10, 12.2.1, 13.1.6, 14.2.8, 2.4.5, 3.2.2, 3.5.8, 5.2.2.17, 5.2.2.30, 5.2.2.37, 5.2.2.57, 5.2.2.61, 5.2.3.25i, 5.2.3.26, 5.2.3.28i, 5.2.3.9, 7.2.3.11, 7.2.3.13, 9.2.2.2

## runs/2007-eirene_fun_7-2/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 82.00 (82–82) |
| L1 accepted | 73.67 (73–74) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 72.00 (72–72) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 56.33 (55–58) |
| L2 components total | 75.33 (74–76) |
| end to end | 56.33 (55–58) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 56.33 (55–58) |
| L1 attempts per split spec | 4.60 (4.50–4.70) |
| minutes | 22.57 (21.49–23.49) |
| weak specs (satisfied by copies and constants) | 35.00 (35–35) |
| end to end, non-trivial spec | 27.00 (26–28) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 56.33 (55–58) |
| specs, requirement | 82.00 (82–82) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 7.33 (7–8) |
| po2 | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 17.33 (14–20) |
| type-error | 1.33 (0–2) |
| unknown-field | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (24): 10.4.1, 11.2.1.10, 11.3.3.5, 12.2.1, 13.1.6, 2.4.5, 3.2.2, 3.5.8, 5.2.2.30, 5.2.2.37, 5.2.2.57, 5.2.2.61, 5.2.2.62, 5.2.3.25i, 5.2.3.25iii, 5.2.3.25ix, 5.2.3.26, 5.2.3.27, 5.2.3.28i, 5.2.3.9, 7.2.3.11, 7.2.3.13, 7.2.3.9i, 9.2.2.2
