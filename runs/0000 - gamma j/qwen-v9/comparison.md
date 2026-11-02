# Before/after: `qwen-v8` → `qwen-v9`

Document: `0000 - gamma j.xml` · model: `qwen`

## Totals

| | qwen-v8 | qwen-v9 | Δ |
|---|---|---|---|
| entries | 75 | 74 | -1 |
| compile | 68 (91%) | 67 (91%) | -1 |
| rejects a bad example | 47 (63%) | 48 (65%) | +1 |
| L0 OK (checked) | 58 (77%) | 59 (80%) | +1 |
| L0 failed | 17 (23%) | 15 (20%) | -2 |
| L0.5 ✅ pass | 56 (75%) | 53 (72%) | -3 |
| L0.5 ⚠️ flag | 11 (15%) | 13 (18%) | +2 |
| L0.5 ❌ fail | 8 (11%) | 8 (11%) | +0 |
| first-attempt OK | 35 (47%) | 32 (43%) | -3 |
| mean attempts | 2.47 | 2.38 | -0.09 |
| total seconds | 1912 | 1830 | -82 |

On the 74 entries present in both runs: L0 OK 58 → 59, L0.5 pass 56 → 53, L0.5 fail 7 → 8.

## Entries added / removed by the parser

| | Entry | Text | L0.5 |
|---|---|---|---|
| − | `1.4/I3` | Confirm Orders | (was ❌) |

## Improved (6)

| Entry | L0 qwen-v8 → qwen-v9 | L0.5 | Reasons now |
|---|---|---|---|
| `1.4/S4` | FAILED → OK | ❌ → ✅ | — |
| `3.1.3/S2` | FAILED → OK | ❌ → ✅ | — |
| `5.1/R7` | OK → OK | ⚠️ → ✅ | — |
| `5.3/R5` | FAILED → OK | ❌ → ✅ | — |
| `UC-customer-register-customer` | FAILED → OK | ❌ → ✅ | — |
| `UC-administrator-install-plug-ins` | OK → OK | ⚠️ → ✅ | — |

## Regressed (11)

| Entry | L0 qwen-v8 → qwen-v9 | L0.5 | Reasons now |
|---|---|---|---|
| `3.1.3/S3` | OK → OK | ✅ → ⚠️ | `pre` is `True`: the spec assumes nothing about the input |
| `3.2.3/S1` | OK → OK | ✅ → ⚠️ | could not test whether `post` rejects anything (no field types to vary) |
| `3.3.3/S2` | OK → FAILED | ✅ → ❌ | does not compile |
| `3.4.3/S1` | OK → OK | ✅ → ⚠️ | could not test whether `post` rejects anything (no field types to vary) |
| `5.1/R9` | OK → OK | ✅ → ⚠️ | `pre` is `True`: the spec assumes nothing about the input |
| `5.3/R3` | OK → FAILED | ✅ → ❌ | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| `5.5/R5` | FAILED → FAILED | ✅ → ❌ | does not compile |
| `DD-credit-card-expiry-date` | OK → FAILED | ⚠️ → ❌ | does not compile |
| `DD-location` | OK → FAILED | ⚠️ → ❌ | does not compile |
| `UC-administrator-add-user` | OK → OK | ✅ → ⚠️ | could not test whether `post` rejects anything (no field types to vary) |
| `UC-sales-person-update-product-attributes` | OK → FAILED | ✅ → ⚠️ | could not test whether `post` rejects anything (no field types to vary) |

## L0 status changed, same L0.5 (10)

| Entry | L0 qwen-v8 → qwen-v9 | L0.5 | Reasons now |
|---|---|---|---|
| `3.3.3/S1` | OK → FAILED | ⚠️ → ⚠️ | `pre` is `True`: the spec assumes nothing about the input |
| `3.4.3/S2` | OK → FAILED | ✅ → ✅ | — |
| `CI-2` | FAILED → OK | ✅ → ✅ | — |
| `DD-item-name` | FAILED → OK | ✅ → ✅ | — |
| `DD-text-description` | OK → FAILED | ✅ → ✅ | — |
| `UC-customer-login-customer` | FAILED → OK | ✅ → ✅ | — |
| `UC-administrator-change-user-properties` | FAILED → OK | ✅ → ✅ | — |
| `UC-administrator-manage-plug-in-options` | FAILED → OK | ✅ → ✅ | — |
| `UC-administrator-install-patch-process` | OK → FAILED | ✅ → ✅ | — |
| `UC-sales-person-login-sales-person` | FAILED → OK | ✅ → ✅ | — |

## Failing L0.5 in qwen-v9 (8)

| Entry | Text | Reasons |
|---|---|---|
| `3.3.3/S2` | The shopping cart will clearly display the number of items in the cart, along with the tot | does not compile |
| `3.5.3/S2` | Customers will be able to search for products matching their search criteria. | does not compile |
| `5.3/R3` | The system shall encrypt all customer data in database. | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| `5.5/R1` | The system shall perform searches via Dijkstra's shortest path algorithm. | does not compile |
| `5.5/R5` | The system shall validate email address existence. | does not compile |
| `DD-credit-card-expiry-date` | The date on the credit card when it will get expired; format MM/YY | does not compile |
| `DD-shipping-date` | Date when the specified order is shipped; format MM/DD/YYYY | does not compile |
| `DD-location` | Place where the item is kept in the warehouse in the form of (aisle, column, shelf) | does not compile |

Model output varies from run to run, so single-entry flips are noisy; compare totals and patterns.
