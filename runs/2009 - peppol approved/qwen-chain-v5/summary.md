## runs/2009 - peppol approved/qwen-chain-v5

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 44.00 (44–44) |
| L1 accepted | 42.00 (41–43) |
| L1 chain (two components) | 1.33 (1–2) |
| L1 single (not split) | 38.00 (38–38) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 2.67 (2–3) |
| L2 components implemented | 31.33 (31–32) |
| L2 components total | 43.33 (42–45) |
| end to end | 30.00 (30–30) |
| end to end, chain | 1.00 (1–1) |
| end to end, single | 29.00 (29–29) |
| L1 attempts per split spec | 3.47 (3.00–3.75) |
| minutes | 12.17 (10.51–13.23) |
| weak specs (satisfied by copies and constants) | 20.00 (20–20) |
| end to end, non-trivial spec | 12.00 (12–12) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 1.00 (1–1) |
| L2 implemented by the harness skeleton alone | 26.33 (26–27) |
| L2 implemented with the model | 5.00 (5–5) |
| L2 result fields written by the harness | 39.33 (38–41) |
| L2 result fields written by the model | 11.33 (11–12) |
| end to end, non-trivial spec, model wrote code | 3.00 (3–3) |
| repair loops stopped early (L1 + L2) | 7.00 (6–8) |
| L1 chain with a repaired second `pre` | 0.33 (0–1) |
| strength of chain architectures (of 6) | 5.17 (5.00–5.50) |
| end to end, requirement | 30.00 (30–30) |
| specs, requirement | 44.00 (44–44) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.33 (0–2) |
| unknown-field | 0.33 (0–1) |
| type-error | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 11.00 (11–11) |
| syntax | 0.67 (0–1) |
| unknown-field | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 4.2/S10 | first (`ComputeEvidenceRetrievalContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.33 (1–2) |

Not end to end in every repetition (14): 0/S17, 0/S6, 3.1.2.2/S2, 3.1.2.9/S1, 3.2.3.1/S1, 3.2.4.10/S4, 3.2.4.9/S9, 3.3.2.3/S1, 3.3.2.9/S3, 3.4.2.6/S3, 3.4.2.9/S2, 4.2/S10, 4.3.1/S8, 4.4.2/S1

## runs/2009 - peppol approved/qwen-chain-v5-fallback

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 44.00 (44–44) |
| L1 accepted | 44.00 (44–44) |
| L1 chain (two components) | 1.67 (1–2) |
| L1 single (not split) | 38.00 (38–38) |
| L1 single-fallback | 1.67 (1–2) |
| L1 not decomposable (identity split → single) | 2.67 (2–3) |
| L2 components implemented | 31.67 (30–33) |
| L2 components total | 45.67 (45–46) |
| end to end | 30.00 (29–31) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 29.33 (29–30) |
| L1 attempts per split spec | 3.56 (3.00–4.00) |
| minutes | 13.48 (11.21–16.70) |
| weak specs (satisfied by copies and constants) | 20.00 (20–20) |
| end to end, non-trivial spec | 12.00 (11–13) |
| weak specs that only pass data through (copy-ok) | 1.00 (1–1) |
| end to end, copy-ok spec | 1.00 (1–1) |
| L2 implemented by the harness skeleton alone | 26.33 (25–27) |
| L2 implemented with the model | 5.33 (5–6) |
| L2 result fields written by the harness | 39.67 (37–41) |
| L2 result fields written by the model | 12.00 (11–13) |
| end to end, non-trivial spec, model wrote code | 3.00 (2–4) |
| repair loops stopped early (L1 + L2) | 5.67 (5–6) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.33 (5.00–5.50) |
| end to end, requirement | 30.00 (29–31) |
| specs, requirement | 44.00 (44–44) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 (fell back to single) | 1.00 (0–2) |
| type-error (fell back to single) | 0.67 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 13.00 (12–14) |
| syntax | 0.67 (0–1) |
| unknown-field | 0.33 (0–1) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | 4.2/S10 | first (`RetrieveEvidencesContract`) | po3 | — |
| rep2 | 4.2/S10 | first (`RetrieveEvidencesContract`) | po3 | — |
| rep3 | 1.1/S4 | first (`ComputeNoticeContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.67 (1–2) |

Not end to end in every repetition (13): 0/S6, 3.1.2.2/S2, 3.1.2.9/S1, 3.2.3.1/S1, 3.2.4.10/S4, 3.2.4.9/S9, 3.3.2.3/S1, 3.3.2.9/S3, 3.4.2.6/S3, 3.4.2.9/S2, 4.2/S10, 4.3.1/S8, 4.4.2/S1

## runs/2009 - peppol approved/qwen-chain-v5-on-v10.1

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 42.00 (42–42) |
| L1 accepted | 41.00 (41–41) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 41.00 (41–41) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 29.67 (29–30) |
| L2 components total | 41.00 (41–41) |
| end to end | 29.67 (29–30) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 29.67 (29–30) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 11.22 (10.26–12.08) |
| weak specs (satisfied by copies and constants) | 16.00 (16–16) |
| end to end, non-trivial spec | 15.00 (15–15) |
| L2 implemented by the harness skeleton alone | 26.00 (26–26) |
| L2 implemented with the model | 3.67 (3–4) |
| L2 result fields written by the harness | 37.00 (37–37) |
| L2 result fields written by the model | 5.00 (4–6) |
| end to end, non-trivial spec, model wrote code | 1.00 (1–1) |
| repair loops stopped early (L1 + L2) | 4.67 (4–5) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 29.67 (29–30) |
| specs, requirement | 42.00 (42–42) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 8.67 (8–9) |
| unknown-field | 1.67 (1–2) |
| unknown-name | 1.00 (1–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (11): 0/I6, 1.1/I2, 1.2/S34, 1.2/S8, 3.1.2.1/S2, 3.1.2.2/S2, 3.2.4.10/S4, 3.4.2.3/S1, 3.4.2.4/S3, 4.4.2/S1, 5.1/S2

## runs/2009 - peppol approved/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 42.00 (42–42) |
| L1 accepted | 41.00 (41–41) |
| L1 chain (two components) | 0.00 (0–0) |
| L1 single (not split) | 41.00 (41–41) |
| L1 single-fallback | 0.00 (0–0) |
| L1 not decomposable (identity split → single) | 0.00 (0–0) |
| L2 components implemented | 27.00 (26–28) |
| L2 components total | 41.00 (41–41) |
| end to end | 27.00 (26–28) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 27.00 (26–28) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 9.77 (8.40–11.45) |
| weak specs (satisfied by copies and constants) | 16.00 (16–16) |
| end to end, non-trivial spec | 13.00 (12–14) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, requirement | 27.00 (26–28) |
| specs, requirement | 42.00 (42–42) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 10.67 (10–11) |
| unknown-field | 2.00 (2–2) |
| unknown-name | 1.00 (1–1) |
| syntax | 0.33 (0–1) |

### Specs with exactly one of two components implemented

none

Not end to end in every repetition (14): 0/I6, 1.1/I2, 1.2/S34, 1.2/S8, 3.1.2.1/S2, 3.1.2.2/S2, 3.2.3.1/S1, 3.2.4.10/S4, 3.3.2.3/S1, 3.4.2.3/S1, 3.4.2.4/S3, 4.2/S10, 4.4.2/S1, 5.1/S2
