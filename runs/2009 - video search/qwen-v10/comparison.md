# `qwen-v8` (1 rep) → `qwen-v10` (1 rep)

Document: `2009 - video search.xml`

- A: no metadata (run before v10)
- B: harness_version `v10`, model_id `qwen2.5-7b-instruct`, temperature `0.2`, prompt_hash `a4ace6f72b38`, git_commit `f8af89f`, seeds [42]

Note: A and B are single runs, so the spread is unknown.

Mean (min–max) over repetitions. A change is real only if the means differ by more than the spread (max − min) of either run.

| metric | A: qwen-v8 | B: qwen-v10 | Δ mean | verdict |
|---|---|---|---|---|
| entries | 19 | 21 | +2.00 | single runs: no spread |
| compiles | 19 | 19 | +0.00 | same |
| checked (L0 OK) | 15 | 16 | +1.00 | single runs: no spread |
| L0.5 pass | 7 | 15 | +8.00 | single runs: no spread |
| L0.5 flag | 9 | 1 | -8.00 | single runs: no spread |
| L0.5 fail | 3 | 5 | +2.00 | single runs: no spread |
| negative: rejects | 10 | 10 | +0.00 | same |
| negative: accepts forbidden | 1 | 0 | -1.00 | single runs: no spread |
| mean attempts | 2.32 | 2.24 | -0.08 | single runs: no spread |

## Entries whose L0.5 pass rate changed (22)

| change | entry | A passed | B passed |
|---|---|---|---|
| down | `REQ-1#2` | 1/1 | 0/1 |
| down | `REQ-5#2` | 1/1 | 0/1 |
| down | `REQ-6#2` | 1/1 | 0/1 |
| up | `REQ-1` | 0/1 | 1/1 |
| up | `REQ-3` | 0/1 | 1/1 |
| up | `REQ-4` | 0/1 | 1/1 |
| up | `REQ-5` | 0/1 | 1/1 |
| up | `REQ-3#2` | 0/1 | 1/1 |
| up | `REQ-4#2` | 0/1 | 1/1 |
| up | `REQ-7#2` | 0/1 | 1/1 |
| up | `REQ-1#3` | 0/1 | 1/1 |
| up | `REQ-2#3` | 0/1 | 1/1 |
| up | `REQ-3#3` | 0/1 | 1/1 |
| up | `REQ-5#3` | 0/1 | 1/1 |
| only in A | `1.3/S1` | 1/1 | — |
| only in A | `1.3/S4` | 0/1 | — |
| only in A | `1.3/S7` | 1/1 | — |
| only in B | `REQ-6` | — | 1/1 |
| only in B | `REQ-8` | — | 0/1 |
| only in B | `REQ-4#3` | — | 1/1 |
| only in B | `REQ-6#3` | — | 0/1 |
| only in B | `REQ-7#3` | — | 0/1 |

2 other entries have the same L0.5 pass rate in A and B.
