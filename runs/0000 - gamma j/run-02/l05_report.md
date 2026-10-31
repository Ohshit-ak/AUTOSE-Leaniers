# L0.5 report — 0000 - gamma j.xml (qwen)

Compiles: 65/75 · ✅ pass 45 · ⚠️ flagged 20 · ❌ fail 10

| | Entry | Kind | Reasons |
|---|---|---|---|
| ❌ | `1.4/I3` | requirement | does not compile |
| ✅ | `1.4/S2` | requirement | — |
| ❌ | `1.4/S3` | requirement | does not compile |
| ✅ | `1.4/S4` | requirement | — |
| ✅ | `3.1.3/S1` | requirement | — |
| ✅ | `3.1.3/S2` | requirement | — |
| ❌ | `3.1.3/S3` | requirement | does not compile |
| ❌ | `3.2.3/S1` | requirement | does not compile |
| ✅ | `3.2.3/S2` | requirement | — |
| ✅ | `3.3.3/S1` | requirement | — |
| ✅ | `3.3.3/S2` | requirement | — |
| ✅ | `3.3.3/S3` | requirement | — |
| ✅ | `3.4.3/S1` | requirement | — |
| ✅ | `3.4.3/S2` | requirement | — |
| ⚠️ | `3.4.3/S3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ✅ | `3.5.3/S2` | requirement | — |
| ✅ | `SI-1.2` | requirement | — |
| ❌ | `CI-1` | requirement | does not compile |
| ✅ | `CI-2` | requirement | — |
| ⚠️ | `5.1/R1` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R2` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R4` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R5` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R6` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R7` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R8` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.1/R9` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.3/R1` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.3/R3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ✅ | `5.3/R4` | requirement | — |
| ✅ | `5.3/R5` | requirement | — |
| ❌ | `5.5/R1` | requirement | does not compile |
| ⚠️ | `5.5/R2` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `5.5/R5` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `DD-user-id` | data_constraint | rejects a valid value "a1a1a1a1a1" (length 10, alphanumeric); accepts an invalid value "#1a1a1a1a1" (contains `#`, not alphanumeric) |
| ✅ | `DD-password` | data_constraint | — |
| ✅ | `DD-item-name` | data_constraint | — |
| ✅ | `DD-item-id` | data_constraint | — |
| ⚠️ | `DD-price` | data_constraint | data tests skipped: `Input` is not one `String` field and `Output` one `Bool` field |
| ✅ | `DD-text-description` | data_constraint | — |
| ⚠️ | `DD-shipping-price` | data_constraint | data tests skipped: `Input` is not one `String` field and `Output` one `Bool` field |
| ⚠️ | `DD-quantity` | data_constraint | data tests skipped: `Input` is not one `String` field and `Output` one `Bool` field |
| ⚠️ | `DD-total` | data_constraint | data tests skipped: `Input` is not one `String` field and `Output` one `Bool` field |
| ✅ | `DD-name` | data_constraint | — |
| ✅ | `DD-city` | data_constraint | — |
| ✅ | `DD-state` | data_constraint | — |
| ✅ | `DD-zip-code` | data_constraint | — |
| ✅ | `DD-e-mail-id` | data_constraint | — |
| ✅ | `DD-credit-card-no` | data_constraint | — |
| ❌ | `DD-credit-card-expiry-date` | data_constraint | does not compile |
| ✅ | `DD-order-no` | data_constraint | — |
| ✅ | `DD-tracking-no` | data_constraint | — |
| ❌ | `DD-shipping-date` | data_constraint | does not compile |
| ❌ | `DD-location` | data_constraint | does not compile |
| ✅ | `UC-customer-register-customer` | use_case | — |
| ✅ | `UC-customer-login-customer` | use_case | — |
| ✅ | `UC-customer-edit-customer-details` | use_case | — |
| ✅ | `UC-customer-logout-customer` | use_case | — |
| ✅ | `UC-customer-add-item-to-cart` | use_case | — |
| ✅ | `UC-customer-checkout-an-order` | use_case | — |
| ✅ | `UC-administrator-login-administrator` | use_case | — |
| ✅ | `UC-administrator-logout-administrator` | use_case | — |
| ✅ | `UC-administrator-add-user` | use_case | — |
| ✅ | `UC-administrator-remove-user` | use_case | — |
| ⚠️ | `UC-administrator-change-user-properties` | use_case | `pre` is `True`: the spec assumes nothing about the input |
| ✅ | `UC-administrator-install-plug-ins` | use_case | — |
| ✅ | `UC-administrator-remove-plug-ins` | use_case | — |
| ✅ | `UC-administrator-manage-plug-in-options` | use_case | — |
| ✅ | `UC-administrator-install-patch-process` | use_case | — |
| ❌ | `UC-sales-person-login-sales-person` | use_case | does not compile |
| ✅ | `UC-sales-person-logout-sales-person` | use_case | — |
| ✅ | `UC-sales-person-add-product` | use_case | — |
| ✅ | `UC-sales-person-remove-product` | use_case | — |
| ✅ | `UC-sales-person-update-product-attributes` | use_case | — |
