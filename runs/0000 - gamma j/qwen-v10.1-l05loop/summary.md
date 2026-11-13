# L0.5 feedback loop — gamma j (2026-11-13)

Job 76346 (`runs/qwen-l05loop-gammaj.sbatch`), commit `8d03bd5`, Qwen 2.5 7B, local.

- **L0 + L0.5:** v10.1 prompt, seed 42, `--on-l0-fail loop`, 2 rounds (`CF_L05_ROUNDS` default)
  → `runs/0000 - gamma j/qwen-v10.1-l05loop/rep1`
- **Chain L1 + L2:** chain-v4, 3 repetitions (seeds 42–44), no `--fallback-single`
  → `runs/0000 - gamma j/qwen-chain-v4-l05loop/rep{1,2,3}`
- **Baseline:** frozen L0 `qwen-v10.1/rep1` and its chain run `qwen-chain-v4`

## Headline

| | before loop | after loop |
|---|---|---|
| L0.5 pass / flag / fail | 57 / 8 / 9 | **62 / 9 / 3** |
| specs into chain L1 (pass only) | 57 | 62 |
| verified end to end (mean of 3 reps) | 46.33 * | **47.33** (47–48) |

\* Without the loop the regenerated specs would have stayed `fail` and been excluded. Of the 5 specs the loop
moved to `pass`, only `UC-sales-person-update-product-attributes` is verified end to end (3 of 3 reps), so
without the loop: 47.33 − 1 = 46.33.

**What the loop did:** 6 of 9 L0.5 failures fixed (5 in round 1, 1 in round 2). 5 became `pass`; 1 became `flag`
(`UC-administrator-login-administrator`). It does not reach L1, because the chain stage reads only `pass` specs.
3 still fail and are excluded, all because they do not compile: `DD-shipping-date`, `UC-customer-add-item-to-cart` and
`UC-customer-checkout-an-order`.

**What happened downstream:** most loop-fixed specs pass L0.5 but still fail later. This was the same in all 3 reps:

| spec | after loop | chain result |
|---|---|---|
| UC-sales-person-update-product-attributes | pass | **verified** 3/3 |
| 3.1.3/S2 | pass | L1 single OK, **L2 PO3 fails** |
| 5.3/R3 | pass | L1 single OK, **L2 PO3 fails** |
| 5.3/R4 | pass | routed to chain, **L1 PO2 fails** |
| 5.5/R1 | pass | routed to chain, **L1 PO2 fails** |

## Comparing with the frozen-L0 run: don't read it as the loop's effect

| | frozen L0 → `qwen-chain-v4` | this run → `qwen-chain-v4-l05loop` |
|---|---|---|
| specs into L1 | 61 | 62 |
| L1 accepted | 58.00 | 56.33 (56–57) |
| end to end | **52.67** (52–53) | **47.33** (47–48) |
| end to end, non-trivial spec | 30.67 | 26.00 |
| L1 failures: PO2 | 0.67 | 4.67 |
| L2 failures: PO3 | 5.33 | 9.33 |

This run's end-to-end count is 5.3 lower, but that comes from regenerating L0, not from the loop. Both runs use
seed 42, but **the L0 prompt changed**: `prompt_hash` is `a4ace6f72b38` in the frozen run (commit `b01f013`) and
`08c8321aa2dd` here (`8d03bd5`). The new L0 was weaker before the loop ran (57 pass vs 63 frozen), and 39 of the
56 shared specs have different Lean text:

- 17 shared specs with **identical** spec text: 17.0 vs 17.0 end to end (no difference)
- 39 shared specs with **different** text: 27.3 vs 32.0. Lost: `1.4/S3`, `3.2.3/S1`, `5.3/R3`, `5.3/R4`,
  `UC-administrator-install-patch-process`, `-install-plug-ins`, `-remove-plug-ins`. Gained: `3.1.3/S3`,
  `SI-1.2`, `UC-administrator-add-user`
- the loop's own net contribution to end to end is +1

The difference between the two L0 runs (prompt change + sampling: −6 pass at L0.5, −5 end to end) is bigger than
what the loop adds. A fair test applies the loop to the **frozen** L0 (run only the check stage with
`--on-l0-fail loop` on a copy of `qwen-v10.1/rep1`), or uses several L0 seeds.

## Takeaways

1. The loop works at L0.5: 9 → 3 failures, so 5 more specs into L1. It costs a few minutes.
2. Specs that pass L0.5 only after feedback are weaker downstream: 1 of 5 verified, vs about 47/57 for the others.
   Passing L0.5 is necessary but not sufficient. The 2 PO2 failures are split routing on these specs.
3. `flag` specs never reach the chain stage, so a fail → flag fix has no effect on end-to-end numbers.
4. The remaining 3 failures are compile errors; 2 rounds with the error text did not fix them.

---

## L0.5 loop: `runs/0000 - gamma j/qwen-v10.1-l05loop/rep1` vs `runs/0000 - gamma j/qwen-v10.1/rep1`

| L0.5 status | baseline run | this run, before loop | this run, after loop |
|---|---|---|---|
| pass | 63 | 57 | 62 |
| flag | 3 | 8 | 9 |
| fail | 8 | 9 | 3 |
| **total** | 74 | 74 | 74 |
| into L1 (pass + flag) | 66 | 65 | 71 |

### Entries the loop regenerated (9)

| entry | kind | rounds | final status | baseline status | remaining problems |
|---|---|---|---|---|---|
| 3.1.3/S2 | requirement | 1 | pass | pass | — |
| 5.3/R3 | requirement | 1 | pass | pass | — |
| 5.3/R4 | requirement | 1 | pass | pass | — |
| 5.5/R1 | requirement | 1 | pass | fail | — |
| DD-shipping-date | data_constraint | 2 | fail | fail | does not compile |
| UC-administrator-login-administrator | use_case | 2 | flag | fail | — |
| UC-customer-add-item-to-cart | use_case | 2 | fail | pass | does not compile |
| UC-customer-checkout-an-order | use_case | 2 | fail | fail | does not compile |
| UC-sales-person-update-product-attributes | use_case | 1 | pass | pass | — |

Loop fixed 6 of 9 regenerated entries.

### Per-entry status, baseline → loop run (same entries)

| baseline → loop | entries |
|---|---|
| pass → pass | 57 |
| pass → flag | 5 |
| pass → fail | 1 |
| flag → pass | 1 |
| flag → flag | 2 |
| fail → pass | 4 |
| fail → flag | 2 |
| fail → fail | 2 |

---

## runs/0000 - gamma j/qwen-chain-v4-l05loop

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 62.00 (62–62) |
| L1 accepted | 56.33 (56–57) |
| L1 chain (two components) | 0.33 (0–1) |
| L1 single (not split) | 56.00 (56–56) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 47.33 (47–48) |
| L2 components total | 56.67 (56–58) |
| end to end | 47.33 (47–48) |
| end to end, chain | 0.00 (0–0) |
| end to end, single | 47.33 (47–48) |
| L1 attempts per split spec | 5.00 (5–5) |
| minutes | 13.95 (13.12–15.15) |
| weak specs (satisfied by copies and constants) | 23.00 (23–23) |
| end to end, non-trivial spec | 26.00 (26–26) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 20.33 (20–21) |
| specs, requirement | 31.00 (31–31) |
| end to end, use_case | 10.00 (10–10) |
| specs, use_case | 14.00 (14–14) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| po2 | 4.67 (4–5) |
| identity | 1.00 (1–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 9.33 (8–11) |

### Specs with exactly one of two components implemented

none

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 0.33 (0–1) |

Not end to end in every repetition (14): 1.4/S3, 3.1.3/S1, 3.1.3/S2, 3.2.3/S1, 3.4.3/S1, 5.3/R1, 5.3/R3, 5.3/R4, 5.3/R5, 5.5/R1, UC-administrator-install-patch-process, UC-administrator-install-plug-ins, UC-administrator-remove-plug-ins, UC-administrator-remove-user

## runs/0000 - gamma j/qwen-chain-v4

3 repetition(s): rep1, rep2, rep3

| metric | mean (min–max) |
|---|---|
| specs | 61.00 (61–61) |
| L1 accepted | 58.00 (58–58) |
| L1 chain (two components) | 1.00 (1–1) |
| L1 single (not split) | 57.00 (57–57) |
| L1 single-fallback | 0.00 (0–0) |
| L2 components implemented | 53.67 (53–54) |
| L2 components total | 59.00 (59–59) |
| end to end | 52.67 (52–53) |
| end to end, chain | 0.67 (0–1) |
| end to end, single | 52.00 (52–52) |
| L1 attempts per split spec | 4.00 (4–4) |
| minutes | 11.51 (10.47–13.07) |
| weak specs (satisfied by copies and constants) | 24.00 (24–24) |
| end to end, non-trivial spec | 30.67 (30–31) |
| L1 chain with a repaired second `pre` | 0.00 (0–0) |
| strength of chain architectures (of 6) | 5.00 (5–5) |
| end to end, data_constraint | 17.00 (17–17) |
| specs, data_constraint | 17.00 (17–17) |
| end to end, requirement | 21.00 (21–21) |
| specs, requirement | 27.00 (27–27) |
| end to end, use_case | 14.67 (14–15) |
| specs, use_case | 17.00 (17–17) |

### L1 failures by class

| class | mean (min–max) |
|---|---|
| identity | 2.00 (2–2) |
| po2 | 0.67 (0–1) |
| type-error | 0.33 (0–1) |

### L2 component failures by class

| class | mean (min–max) |
|---|---|
| po3 | 5.33 (5–6) |

### Specs with exactly one of two components implemented

| rep | spec | failed component | class | structural cause |
|---|---|---|---|---|
| rep1 | UC-customer-login-customer | second (`GenerateOutputContract`) | po3 | — |

### Accepted two-component architectures under the current routing and static check

| verdict | mean (min–max) |
|---|---|
| real decomposition | 1.00 (1–1) |

Not end to end in every repetition (8): 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 5.1/R5, 5.3/R5, SI-1.2, UC-administrator-add-user, UC-administrator-remove-user
