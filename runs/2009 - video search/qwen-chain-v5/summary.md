## runs/2009 - video search/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 20.00 (20–20) |
| L1 accepted | 19.67 (19–20) |
| L1 chain (two components) | 3.00 (3–3) |
| L1 single (not split) | 16.00 (16–16) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.67 (0–1) |
| L2 components implemented | 15.33 (15–16) |
| L2 components total | 22.67 (22–23) |
| end to end | 12.33 (12–13) |
| end to end, chain | 2.67 (2–3) |
| end to end, single | 9.67 (9–10) |
| L1 attempts per split spec | 1.33 (1–2) |
| minutes | 6.70 (6.32–7.16) |
| weak specs (satisfied by copies and constants) | 6.00 (6–6) |
| end to end, non-trivial spec | 6.33 (6–7) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 5.00 (5–5) |
| L2 implemented with the model | 10.33 (10–11) |
| L2 result fields written by the harness | 8.67 (8–10) |
| L2 result fields written by the model | 12.33 (11–14) |
| end to end, non-trivial spec, model wrote code | 5.33 (5–6) |
| repair loops stopped early (L1 + L2) | 4.00 (3–5) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 12.33 (12–13) |
| specs, requirement | 20.00 (20–20) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.33 (7–8) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | REQ-1#2 | second (`FormatMessageContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.00 (3–3) |

Not end to end in every repetition (7): REQ-1, REQ-3, REQ-4, REQ-5#2, REQ-6, REQ-6#2, REQ-6#3

## runs/2009 - video search/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 20.00 (20–20) |
| L1 accepted | 20.00 (20–20) |
| L1 chain (two components) | 3.33 (3–4) |
| L1 single (not split) | 16.00 (16–16) |
| L1 single-fallback | 0.33 (0–1) |
| L1 not decomposable (identity split → single) | 0.33 (0–1) |
| L2 components implemented | 15.00 (14–16) |
| L2 components total | 23.33 (23–24) |
| end to end | 11.67 (11–12) |
| end to end, chain | 2.33 (2–3) |
| end to end, single | 9.33 (9–10) |
| L1 attempts per split spec | 1.61 (1.25–2.25) |
| minutes | 7.35 (5.95–8.91) |
| weak specs (satisfied by copies and constants) | 6.00 (6–6) |
| end to end, non-trivial spec | 5.67 (5–6) |
| weak specs that only pass data through (copy-ok) | 0.00 (0–0) |
| end to end, copy-ok spec | 0.00 (0–0) |
| L2 implemented by the harness skeleton alone | 5.33 (5–6) |
| L2 implemented with the model | 9.67 (9–10) |
| L2 result fields written by the harness | 9.00 (8–11) |
| L2 result fields written by the model | 11.00 (10–12) |
| end to end, non-trivial spec, model wrote code | 4.67 (4–5) |
| repair loops stopped early (L1 + L2) | 5.00 (4–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 11.67 (11–12) |
| specs, requirement | 20.00 (20–20) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 7.67 (7–8) |
| unknown-field | 0.33 (0–1) |
| unknown-name | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | REQ-5 | second (`ShowResultsContract`) | po3 | — |
| rep2 | REQ-5 | second (`ShowResultsContract`) | po3 | — |
| rep3 | REQ-5 | second (`ShowResultsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 3.33 (3–4) |

Not end to end in every repetition (8): REQ-1, REQ-3, REQ-4, REQ-5, REQ-5#2, REQ-6, REQ-6#2, REQ-6#3

## runs/2009 - video search/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 14.00 (14–14) |
| L1 chain (two components) | 2.67 (2–3) |
| L1 single (not split) | 11.00 (11–11) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.33 (0–1) |
| L2 components implemented | 13.00 (11–14) |
| L2 components total | 16.67 (16–17) |
| end to end | 10.33 (9–11) |
| end to end, chain | 1.00 (0–2) |
| end to end, single | 9.33 (9–10) |
| L1 attempts per split spec | 2.11 (2.00–2.33) |
| minutes | 4.42 (3.74–5.02) |
| weak specs (satisfied by copies and constants) | 6.00 (6–6) |
| end to end, non-trivial spec | 4.33 (3–5) |
| L2 implemented by the harness skeleton alone | 4.00 (4–4) |
| L2 implemented with the model | 9.00 (7–10) |
| L2 result fields written by the harness | 5.33 (4–6) |
| L2 result fields written by the model | 9.33 (7–11) |
| end to end, non-trivial spec, model wrote code | 3.33 (2–4) |
| repair loops stopped early (L1 + L2) | 0.67 (0–2) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, requirement | 10.33 (9–11) |
| specs, requirement | 15.00 (15–15) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 3.00 (2–4) |
| unknown-field | 0.33 (0–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | REQ-5 | second (`ShowResultsContract`) | po3 | — |
| rep1 | REQ-7#2 | second (`ShowResultsContract`) | unknown-field | — |
| rep2 | REQ-3 | first (`ComputeResultsContract`) | syntax | — |
| rep2 | REQ-5 | second (`ShowResultsContract`) | po3 | — |
| rep3 | REQ-5 | second (`ShowResultsContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 2.67 (2–3) |

Not end to end in every repetition (3): REQ-4, REQ-5, REQ-6

## runs/2009 - video search/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 15.00 (15–15) |
| L1 accepted | 13.67 (13–14) |
| L1 chain (two components) | 2.67 (2–3) |
| L1 single (not split) | 11.00 (11–11) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
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
