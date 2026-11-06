# L1: `qwen-L1-v1-nograph` (3 reps) vs `qwen-L1-v1` (3 reps)

- A: graph mode `no-graph`, arch mode `pipeline`, model `qwen2.5-7b-instruct`, prompt `584a3d01b3f2`, graph `4d89a5e3e5dd`, commit `dd491bb`; modes used ['none', 'pipeline']
- B: graph mode `graph`, arch mode `pipeline`, model `qwen2.5-7b-instruct`, prompt `584a3d01b3f2`, graph `4d89a5e3e5dd`, commit `dd491bb`; modes used ['pipeline']

Mean (min–max) over repetitions; a difference is real only beyond the spread.

| metric | A | B | Δ mean | verdict |
|---|---|---|---|---|
| groups | 1 (1–1) | 1 (1–1) | +0.00 | same |
| groups accepted | 0 (0–0) | 0 (0–0) | +0.00 | same |
| Arch.lean compiles | 0.33 (0–1) | 1 (1–1) | +0.67 | within noise |
| components | 1.33 (0–4) | 2 (2–2) | +0.67 | within noise |
| operations | 16 (0–48) | 48 (48–48) | +32.00 | within noise |
| contracts satisfiable % | 33.33 (0–100) | 100 (100–100) | +66.67 | within noise |
| contracts non-vacuous % | 33.33 (0–100) | 100 (100–100) | +66.67 | within noise |
| placeholders (no contract) | 0 (0–0) | 0 (0–0) | +0.00 | same |
| trace proved % | 33 (0–99) | 99 (99–99) | +66.00 | within noise |
| PO1 proved % | 33.33 (0–100) | 100 (100–100) | +66.67 | within noise |
| PO1 pairs | 1 (0–3) | 1 (1–1) | +0.00 | same |
| PO2 proved | 0 (0–0) | 0 (0–0) | +0.00 | same |
| mean attempts per operation | 0.36 (0–1.08) | 1.12 (1.1–1.15) | +0.76 | within noise |
| tool calls | 0 (0–0) | 0 (0–0) | +0.00 | same |
| minutes | 4.57 (0.9–11.8) | 12.23 (11.4–13.2) | +7.67 | within noise |
| failed attempts: syntax | 0.33 (0–1) | 0.33 (0–1) | +0.00 | same |
| failed attempts: names | 0 (0–0) | 0 (0–0) | +0.00 | same |
| failed attempts: types | 0.33 (0–1) | 0 (0–0) | -0.33 | within noise |
| failed attempts: proof | 0 (0–0) | 0 (0–0) | +0.00 | same |
| failed attempts: check | 0.67 (0–2) | 6.33 (5–7) | +5.67 | **worse** |
| failed attempts: other | 0 (0–0) | 0 (0–0) | +0.00 | same |
| failed attempts: truncated | 0 (0–0) | 0 (0–0) | +0.00 | same |
| failed attempts: weakened | 0.33 (0–1) | 0.33 (0–1) | +0.00 | same |

## Most common obligation errors in A

- 1× `Expected type must not contain free variables` — e.g. AccountSys trace_post:Accounts:3.5.3/S2: Expected type must not contain free variables
- 1× `needs _ trace lemmas first, e.g. trace_post:Accounts:_._._/S_` — e.g. AccountSys po2: needs 1 trace lemmas first, e.g. trace_post:Accounts:3.5.3/S2

## Most common obligation errors in B

- 3× `Expected type must not contain free variables` — e.g. AccountSys trace_post:Account:3.5.3/S2: Expected type must not contain free variables
- 3× `needs _ trace lemmas first, e.g. trace_post:Account:_._._/S_` — e.g. AccountSys po2: needs 1 trace lemmas first, e.g. trace_post:Account:3.5.3/S2
