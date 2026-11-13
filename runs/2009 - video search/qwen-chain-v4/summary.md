## runs/2009 - video search/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 13.67 (13–14) |
| L1 chain (two components) | 2.67 (2–3) |
| L1 single (not split) | 11.00 (11–11) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 13.33 (12–14) |
| L2 components total | 16.33 (15–17) |
| end to end | 10.67 (10–11) |
| end to end, chain | 2.33 (2–3) |
| end to end, single | 8.33 (8–9) |
| L1 attempts per split spec | 2.33 (2–3) |
| minutes | 4.15 (4.11–4.17) |
| weak specs (satisfied by copies and constants) | 6.00 (6–6) |
| end to end, non-trivial spec | 4.67 (4–5) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 10.67 (10–11) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.00 (1–1) |
| identity | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 2.67 (2–3) |
| unknown-name | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep2 | REQ-3 | first (`ComputeResultsContract`) | unknown-name | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 2.67 (2–3) |

Not end to end in every repetition (3): REQ-1, REQ-4, REQ-6

## runs/2009 - video search/qwen-chain-v4-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 15.00 (15–15) |
| L1 chain (two components) | 2.67 (2–3) |
| L1 single (not split) | 11.00 (11–11) |
| L1 single-fallback | 1.33 (1–2) |
| L2 components implemented | 13.33 (11–15) |
| L2 components total | 17.67 (17–18) |
| end to end | 10.67 (9–12) |
| end to end, chain | 2.00 (1–3) |
| end to end, single | 8.67 (8–9) |
| L1 attempts per split spec | 2.33 (2–3) |
| minutes | 5.93 (4.84–7.02) |
| weak specs (satisfied by copies and constants) | 6.00 (6–6) |
| end to end, non-trivial spec | 4.67 (3–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 10.67 (9–12) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 1.00 (1–1) |
| identity (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 4.33 (3–6) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | REQ-7#2 | second (`ShowResultsContract`) | po3 | — |
| rep2 | REQ-7#2 | second (`ShowResultsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 2.67 (2–3) |

Not end to end in every repetition (3): REQ-1, REQ-4, REQ-6

## runs/2009 - video search/qwen-chain-v3

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 8.67 (8–9) |
| L1 chain (two components) | 3.67 (3–4) |
| L1 single (not split) | 5.00 (5–5) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 9.33 (8–10) |
| L2 components total | 12.33 (11–13) |
| end to end | 6.67 (6–7) |
| end to end, chain | 1.67 (1–2) |
| end to end, single | 5.00 (5–5) |
| L1 attempts per split spec | 3.83 (3.70–4.00) |
| minutes | 6.78 (6.67–6.85) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 5) | 4.19 (4.00–4.33) |
| end to end, requirement | 6.67 (6–7) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 4.00 (4–4) |
| identity | 1.33 (1–2) |
| po1 | 0.67 (0–1) |
| visibility | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 2.33 (1–4) |
| unknown-field | 0.67 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | REQ-7#2 | second (`ShowResultsContract`) | po3 | — |
| rep2 | REQ-3#2 | second (`ResultsCheckContract`) | po3 | — |
| rep3 | REQ-3 | second (`ShowResultsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 2.33 (2–3) |
| single-step spec (not split now) | 1.33 (1–2) |

Not end to end in every repetition (8): REQ-1, REQ-2, REQ-3, REQ-3#2, REQ-4, REQ-4#2, REQ-4#3, REQ-6
