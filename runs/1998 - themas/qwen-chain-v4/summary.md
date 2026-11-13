## runs/1998 - themas/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 19.00 (19–19) |
| L1 accepted | 16.33 (16–17) |
| L1 chain (two components) | 0.33 (0–1) |
| L1 single (not split) | 16.00 (16–16) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 13.00 (12–15) |
| L2 components total | 16.67 (16–18) |
| end to end | 12.67 (12–14) |
| end to end, chain | 0.33 (0–1) |
| end to end, single | 12.33 (12–13) |
| L1 attempts per split spec | 4.56 (3.67–5.00) |
| minutes | 4.80 (4.56–5.24) |
| weak specs (satisfied by copies and constants) | 11.00 (11–11) |
| end to end, non-trivial spec | 2.67 (2–4) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 12.67 (12–14) |
| specs, requirement | 19.00 (19–19) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 2.33 (2–3) |
| identity | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 3.67 (3–4) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.33 (0–1) |

Not end to end in every repetition (5): 3.1.1.2.1/S1, 3.1.1.2.3/S2, 3.1.10.3/S3, 3.1.5.1.3/S3, 3.1.7.3/S1

## runs/1998 - themas/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 19.00 (19–19) |
| L1 accepted | 19.00 (19–19) |
| L1 chain (two components) | 0.33 (0–1) |
| L1 single (not split) | 16.00 (16–16) |
| L1 single-fallback | 2.67 (2–3) |
| L2 components implemented | 15.00 (15–15) |
| L2 components total | 19.33 (19–20) |
| end to end | 14.67 (14–15) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 14.67 (14–15) |
| L1 attempts per split spec | 4.89 (4.67–5.00) |
| minutes | 5.62 (5.41–5.78) |
| weak specs (satisfied by copies and constants) | 11.00 (11–11) |
| end to end, non-trivial spec | 3.67 (3–4) |
| L1 chain with a repaired second `pre` | 0.33 (0–1) |
| end to end, requirement | 14.67 (14–15) |
| specs, requirement | 19.00 (19–19) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 2.67 (2–3) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 4.33 (4–5) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep3 | 3.1.3.3/S3 | second (`HandleErrorContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.33 (0–1) |

Not end to end in every repetition (4): 3.1.1.2.1/S1, 3.1.1.2.3/S2, 3.1.10.3/S3, 3.1.5.1.3/S3
