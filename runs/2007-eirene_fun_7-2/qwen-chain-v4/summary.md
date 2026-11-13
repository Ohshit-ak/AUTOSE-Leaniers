## runs/2007-eirene_fun_7-2/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 82.00 (82–82) |
| L1 accepted | 73.67 (73–74) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 72.00 (72–72) |
| L1 single-fallback | 0.00 (0–0) |
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

## runs/2007-eirene_fun_7-2/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 82.00 (82–82) |
| L1 accepted | 82.00 (82–82) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 72.00 (72–72) |
| L1 single-fallback | 8.67 (8–9) |
| L2 components implemented | 61.00 (60–62) |
| L2 components total | 83.33 (83–84) |
| end to end | 61.00 (60–62) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 61.00 (60–62) |
| L1 attempts per split spec | 4.63 (4.50–4.70) |
| minutes | 22.94 (22.22–23.34) |
| weak specs (satisfied by copies and constants) | 35.00 (35–35) |
| end to end, non-trivial spec | 29.00 (28–30) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 61.00 (60–62) |
| specs, requirement | 82.00 (82–82) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity (fell back to single) | 7.67 (7–8) |
| po2 (fell back to single) | 1.00 (0–2) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 20.67 (19–23) |
| unknown-field | 1.00 (1–1) |
| type-error | 0.67 (0–1) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (19): 11.2.1.10, 11.3.3.5, 12.2.1, 13.1.6, 2.4.5, 3.2.2, 3.5.8, 5.2.2.17, 5.2.2.30, 5.2.2.37, 5.2.2.57, 5.2.2.61, 5.2.3.25i, 5.2.3.26, 5.2.3.28i, 5.2.3.9, 7.2.3.11, 7.2.3.13, 9.2.2.2
