# L0.5 report — 0000 - gamma j.xml (qwen)

Compiles: 71/74 · rejects a bad example: 47 · ✅ pass 62 · ⚠️ flagged 9 · ❌ fail 3

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `1.4/S2` | requirement | — |
| ✅ | `1.4/S3` | requirement | — |
| ✅ | `1.4/S4` | requirement | — |
| ✅ | `3.1.3/S1` | requirement | — |
| ✅ | `3.1.3/S2` | requirement | — |
| ✅ | `3.1.3/S3` | requirement | — |
| ✅ | `3.2.3/S1` | requirement | — |
| ✅ | `3.2.3/S2` | requirement | — |
| ✅ | `3.3.3/S1` | requirement | — |
| ✅ | `3.3.3/S2` | requirement | — |
| ✅ | `3.3.3/S3` | requirement | — |
| ✅ | `3.4.3/S1` | requirement | — |
| ✅ | `3.4.3/S2` | requirement | — |
| ✅ | `3.4.3/S3` | requirement | — |
| ⚠️ | `3.5.3/S2` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `SI-1.2` | requirement | — |
| ✅ | `CI-1` | requirement | — |
| ✅ | `CI-2` | requirement | — |
| ✅ | `5.1/R1` | requirement | — |
| ⚠️ | `5.1/R2` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `5.1/R3` | requirement | — |
| ✅ | `5.1/R4` | requirement | — |
| ⚠️ | `5.1/R5` | requirement | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ✅ | `5.1/R6` | requirement | — |
| ✅ | `5.1/R7` | requirement | — |
| ✅ | `5.1/R8` | requirement | — |
| ✅ | `5.1/R9` | requirement | — |
| ✅ | `5.3/R1` | requirement | — |
| ✅ | `5.3/R3` | requirement | — |
| ✅ | `5.3/R4` | requirement | — |
| ✅ | `5.3/R5` | requirement | — |
| ✅ | `5.5/R1` | requirement | — |
| ✅ | `5.5/R2` | requirement | — |
| ✅ | `5.5/R5` | requirement | — |
| ✅ | `DD-user-id` | data_constraint | — |
| ⚠️ | `DD-password` | data_constraint | data tests skipped: `Input` is not one `String` field and `Output` one `Bool` field |
| ✅ | `DD-item-name` | data_constraint | — |
| ✅ | `DD-item-id` | data_constraint | — |
| ✅ | `DD-price` | data_constraint | — |
| ✅ | `DD-text-description` | data_constraint | — |
| ✅ | `DD-shipping-price` | data_constraint | — |
| ✅ | `DD-quantity` | data_constraint | — |
| ✅ | `DD-total` | data_constraint | — |
| ✅ | `DD-name` | data_constraint | — |
| ✅ | `DD-city` | data_constraint | — |
| ✅ | `DD-state` | data_constraint | — |
| ✅ | `DD-zip-code` | data_constraint | — |
| ✅ | `DD-e-mail-id` | data_constraint | — |
| ✅ | `DD-credit-card-no` | data_constraint | — |
| ⚠️ | `DD-credit-card-expiry-date` | data_constraint | rejects a valid value "11/11" (matches the format MM/YY) |
| ✅ | `DD-order-no` | data_constraint | — |
| ✅ | `DD-tracking-no` | data_constraint | — |
| ❌ | `DD-shipping-date` | data_constraint | does not compile |
| ✅ | `DD-location` | data_constraint | — |
| ✅ | `UC-customer-register-customer` | use_case | — |
| ⚠️ | `UC-customer-login-customer` | use_case | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ✅ | `UC-customer-edit-customer-details` | use_case | — |
| ✅ | `UC-customer-logout-customer` | use_case | — |
| ❌ | `UC-customer-add-item-to-cart` | use_case | does not compile |
| ❌ | `UC-customer-checkout-an-order` | use_case | does not compile |
| ⚠️ | `UC-administrator-login-administrator` | use_case | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { accounts := [{ username := "admin", password := "wrong", email := "admin@example.com", role := "Administrator" }], username := "admin", password := "wrong" } { loggedIn := true, cookie := "abc123" }` holds, but the requirement forbids this  |
| ⚠️ | `UC-administrator-logout-administrator` | use_case | could not test whether `post` rejects anything (no field types to vary) |
| ✅ | `UC-administrator-add-user` | use_case | — |
| ✅ | `UC-administrator-remove-user` | use_case | — |
| ✅ | `UC-administrator-change-user-properties` | use_case | — |
| ✅ | `UC-administrator-install-plug-ins` | use_case | — |
| ✅ | `UC-administrator-remove-plug-ins` | use_case | — |
| ⚠️ | `UC-administrator-manage-plug-in-options` | use_case | compiles, but the generation loop's own checks failed: L0.5: The example gives `Spec.pre` and `Spec.post` different input records. Use exactly the same input record in both. |
| ✅ | `UC-administrator-install-patch-process` | use_case | — |
| ✅ | `UC-sales-person-login-sales-person` | use_case | — |
| ✅ | `UC-sales-person-logout-sales-person` | use_case | — |
| ✅ | `UC-sales-person-add-product` | use_case | — |
| ✅ | `UC-sales-person-remove-product` | use_case | — |
| ✅ | `UC-sales-person-update-product-attributes` | use_case | — |
