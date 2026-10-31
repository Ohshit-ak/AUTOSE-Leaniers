# Lean compile errors — gamma j, Qwen v6

Each saved file in `runs/0000 - gamma j/qwen-v6/lean/` compiled on its own with `lake env lean <file>` from `framework/` (Lean 4.29.1, `lake build` up to date). **64/75 compile, 11 fail.**

Compiling is not passing: 4 files compile but failed the L0.5 vacuity check (`post` accepts any output), so 60/75 count as checked.

**Harness bug found here:** `llm.extract_lean` joins every fenced block in a reply. When the model writes the whole spec twice (e.g. a first and a corrected version), both copies are saved and Lean reports `Input has already been declared` (5.3/R5, DD-credit-card-expiry-date). These errors come from the harness, not the model.

## Errors by category

| Category | Errors |
|---|---|
| unknown field / invented API | 15 |
| missing instance | 8 |
| duplicate declaration (harness joined 2 code blocks) | 7 |
| bad structure literal | 2 |
| example false / decide failed | 2 |
| type mismatch | 2 |
| not a function | 1 |

## All files

| File | Kind | Compiles | Errors | Warnings | Checked (L0 + L0.5) |
|---|---|---|---|---|---|
| `1.4_I3` | requirement | ✅ | 0 | 0 | yes |
| `1.4_S2` | requirement | ✅ | 0 | 0 | yes |
| `1.4_S3` | requirement | ✅ | 0 | 0 | yes |
| `1.4_S4` | requirement | ✅ | 0 | 0 | yes |
| `3.1.3_S1` | requirement | ✅ | 0 | 0 | yes |
| `3.1.3_S2` | requirement | ✅ | 0 | 0 | yes |
| `3.1.3_S3` | requirement | ❌ | 2 | 0 | no |
| `3.2.3_S1` | requirement | ❌ | 6 | 0 | no |
| `3.2.3_S2` | requirement | ✅ | 0 | 0 | yes |
| `3.3.3_S1` | requirement | ✅ | 0 | 0 | yes |
| `3.3.3_S2` | requirement | ✅ | 0 | 0 | yes |
| `3.3.3_S3` | requirement | ✅ | 0 | 0 | yes |
| `3.4.3_S1` | requirement | ✅ | 0 | 0 | yes |
| `3.4.3_S2` | requirement | ✅ | 0 | 0 | yes |
| `3.4.3_S3` | requirement | ✅ | 0 | 0 | yes |
| `3.5.3_S2` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R1` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R2` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R3` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R4` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R5` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R6` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R7` | requirement | ✅ | 0 | 1 | yes |
| `5.1_R8` | requirement | ✅ | 0 | 0 | yes |
| `5.1_R9` | requirement | ✅ | 0 | 0 | yes |
| `5.3_R1` | requirement | ✅ | 0 | 0 | no |
| `5.3_R3` | requirement | ✅ | 0 | 1 | yes |
| `5.3_R4` | requirement | ✅ | 0 | 0 | yes |
| `5.3_R5` | requirement | ❌ | 6 | 0 | no |
| `5.5_R1` | requirement | ❌ | 1 | 1 | no |
| `5.5_R2` | requirement | ✅ | 0 | 0 | no |
| `5.5_R5` | requirement | ❌ | 2 | 1 | no |
| `CI-1` | requirement | ✅ | 0 | 0 | yes |
| `CI-2` | requirement | ✅ | 0 | 0 | yes |
| `DD-city` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-credit-card-expiry-date` | data_constraint | ❌ | 5 | 2 | no |
| `DD-credit-card-no` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-e-mail-id` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-item-id` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-item-name` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-location` | data_constraint | ❌ | 6 | 1 | no |
| `DD-name` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-order-no` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-password` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-price` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-quantity` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-shipping-date` | data_constraint | ❌ | 3 | 1 | no |
| `DD-shipping-price` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-state` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-text-description` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-total` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-tracking-no` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-user-id` | data_constraint | ✅ | 0 | 0 | yes |
| `DD-zip-code` | data_constraint | ✅ | 0 | 0 | yes |
| `SI-1.2` | requirement | ✅ | 0 | 0 | yes |
| `UC-administrator-add-user` | use_case | ✅ | 0 | 0 | yes |
| `UC-administrator-change-user-properties` | use_case | ❌ | 1 | 1 | no |
| `UC-administrator-install-patch-process` | use_case | ✅ | 0 | 0 | yes |
| `UC-administrator-install-plug-ins` | use_case | ✅ | 0 | 0 | yes |
| `UC-administrator-login-administrator` | use_case | ✅ | 0 | 0 | yes |
| `UC-administrator-logout-administrator` | use_case | ✅ | 0 | 1 | yes |
| `UC-administrator-manage-plug-in-options` | use_case | ✅ | 0 | 0 | yes |
| `UC-administrator-remove-plug-ins` | use_case | ✅ | 0 | 0 | no |
| `UC-administrator-remove-user` | use_case | ✅ | 0 | 0 | no |
| `UC-customer-add-item-to-cart` | use_case | ❌ | 1 | 0 | no |
| `UC-customer-checkout-an-order` | use_case | ✅ | 0 | 0 | yes |
| `UC-customer-edit-customer-details` | use_case | ✅ | 0 | 0 | yes |
| `UC-customer-login-customer` | use_case | ❌ | 4 | 1 | no |
| `UC-customer-logout-customer` | use_case | ✅ | 0 | 1 | yes |
| `UC-customer-register-customer` | use_case | ✅ | 0 | 0 | yes |
| `UC-sales-person-add-product` | use_case | ✅ | 0 | 0 | yes |
| `UC-sales-person-login-sales-person` | use_case | ✅ | 0 | 0 | yes |
| `UC-sales-person-logout-sales-person` | use_case | ✅ | 0 | 1 | yes |
| `UC-sales-person-remove-product` | use_case | ✅ | 0 | 0 | yes |
| `UC-sales-person-update-product-attributes` | use_case | ✅ | 0 | 0 | yes |

## Errors per failing file

### ❌ `3.1.3/S3` (requirement)

> Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.

**Error 1** — line 55:22 · bad structure literal

```lean
 55 |                       profile_updated := true }
```

```text
field `profile_updated` has already been specified
```

**Error 2** — line 56:20 · bad structure literal

```lean
 56 |                     { profile_updated := true } := by
```

```text
Fields missing: `credit_card_number`, `address_line1`, `address_line2`, `address_city`, `address_state`, `address_zip`

Hint: Add missing fields:
  
  ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲c̲r̲e̲d̲i̲t̲_̲c̲a̲r̲d̲_̲n̲u̲m̲b̲e̲r̲ ̲:̲=̲ ̲_̲
  ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲a̲d̲d̲r̲e̲s̲s̲_̲l̲i̲n̲e̲1̲ ̲:̲=̲ ̲_̲
  ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲a̲d̲d̲r̲e̲s̲s̲_̲l̲i̲n̲e̲2̲ ̲:̲=̲ ̲_̲
  ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲a̲d̲d̲r̲e̲s̲s̲_̲c̲i̲t̲y̲ ̲:̲=̲ ̲_̲
  ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲a̲d̲d̲r̲e̲s̲s̲_̲s̲t̲a̲t̲e̲ ̲:̲=̲ ̲_̲
  ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲a̲d̲d̲r̲e̲s̲s̲_̲z̲i̲p̲ ̲:̲=̲ ̲_̲
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Input where
  8 |   profile_updated : Bool
  9 |   credit_card_number : String
 10 |   address_line1      : String
 11 |   address_line2      : Option String
 12 |   address_city       : String
 13 |   address_state      : String
 14 |   address_zip        : String
 15 |   deriving DecidableEq, Repr
 16 | 
 17 | structure Output where
 18 |   profile_updated : Bool
 19 |   credit_card_number : String
 20 |   address_line1      : String
 21 |   address_line2      : Option String
 22 |   address_city       : String
 23 |   address_state      : String
 24 |   address_zip        : String
 25 |   deriving DecidableEq, Repr
 26 | 
 27 | def Spec : Contract Input Output where
 28 |   pre  := fun i => i.credit_card_number ≠ "" ∧
 29 |                    i.address_line1 ≠ "" ∧
 30 |                    i.address_city ≠ "" ∧
 31 |                    i.address_state ≠ "" ∧
 32 |                    i.address_zip ≠ ""
 33 |   post := fun i o => o.profile_updated = true ∧
 34 |                      (o.credit_card_number = i.credit_card_number ∧
 35 |                       o.address_line1 = i.address_line1 ∧
 36 |                       o.address_line2 = i.address_line2 ∧
 37 |                       o.address_city = i.address_city ∧
 38 |                       o.address_state = i.address_state ∧
 39 |                       o.address_zip = i.address_zip)
 40 | 
 41 | example : Spec.pre { profile_updated := true,
 42 |                      credit_card_number := "1234567812345678",
 43 |                      address_line1 := "123 Main St",
 44 |                      address_line2 := none,
 45 |                      address_city := "Anytown",
 46 |                      address_state := "CA",
 47 |                      address_zip := "12345" } ∧
 48 |           Spec.post { profile_updated := true,
 49 |                       credit_card_number := "1234567812345678",
 50 |                       address_line1 := "123 Main St",
 51 |                       address_line2 := none,
 52 |                       address_city := "Anytown",
 53 |                       address_state := "CA",
 54 |                       address_zip := "12345",
 55 |                       profile_updated := true } 
 56 |                     { profile_updated := true } := by
 57 |   unfold Spec; decide
```

</details>

### ❌ `3.2.3/S1` (requirement)

> Products will be stored in multi-tiered categories; a category can contain sub categories or products.

**Error 1** — line 11:11 · missing instance

```lean
 11 |   deriving DecidableEq, Repr
```

```text
None of the deriving handlers for class `DecidableEq` applied to `Category`
```

**Error 2** — line 15:11 · missing instance · `lean.synthInstanceFailed`

```lean
 15 |   deriving DecidableEq, Repr
```

```text
failed to synthesize instance of type class
  Decidable (a✝ = b✝)

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

**Error 3** — line 15:24 · missing instance · `lean.synthInstanceFailed`

```lean
 15 |   deriving DecidableEq, Repr
```

```text
failed to synthesize instance of type class
  Repr (List Category)

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

**Error 4** — line 19:11 · missing instance · `lean.synthInstanceFailed`

```lean
 19 |   deriving DecidableEq, Repr
```

```text
failed to synthesize instance of type class
  Decidable (a✝ = b✝)

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

**Error 5** — line 19:24 · missing instance · `lean.synthInstanceFailed`

```lean
 19 |   deriving DecidableEq, Repr
```

```text
failed to synthesize instance of type class
  Repr (List Category)

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

**Error 6** — line 31:15 · missing instance

```lean
 31 |   unfold Spec; decide
```

```text
failed to synthesize
  Decidable
    ({ pre := fun i => i.categories.Nodup, post := fun i o => o.categories = i.categories }.pre
        {
          categories :=
            [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
              { name := "Books", categories := [], products := ["Math", "Physics"] }] } ∧
      { pre := fun i => i.categories.Nodup, post := fun i o => o.categories = i.categories }.post
        {
          categories :=
            [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
              { name := "Books", categories := [], products := ["Math", "Physics"] }] }
        {
          categories :=
            [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
              { name := "Books", categories := [], products := ["Math", "Physics"] }] })

Hint: Additional diagnostic information may be available using the `set_option diagnostics true` command.
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Category where
  8 |   name    : String
  9 |   categories : List Category
 10 |   products : List String
 11 |   deriving DecidableEq, Repr
 12 | 
 13 | structure Input where
 14 |   categories : List Category
 15 |   deriving DecidableEq, Repr
 16 | 
 17 | structure Output where
 18 |   categories : List Category
 19 |   deriving DecidableEq, Repr
 20 | 
 21 | def Spec : Contract Input Output where
 22 |   pre  := fun i => i.categories.Nodup
 23 |   post := fun i o => o.categories = i.categories
 24 | 
 25 | example : Spec.pre { categories := [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
 26 |                                       { name := "Books", categories := [], products := ["Math", "Physics"] }] } ∧
 27 |           Spec.post { categories := [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
 28 |                                       { name := "Books", categories := [], products := ["Math", "Physics"] }] }
 29 |                     { categories := [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
 30 |                                      { name := "Books", categories := [], products := ["Math", "Physics"] }] } := by
 31 |   unfold Spec; decide
```

</details>

### ❌ `5.3/R5` (requirement)

> The system shall detect consecutive failed login attempts.

**Error 1** — line 38:15 · example false / decide failed

```lean
 38 |   unfold Spec; decide
```

```text
Tactic `decide` proved that the proposition
  { pre := fun i => i.username ≠ "" ∧ i.password ≠ "",
          post := fun i o =>
            (o.signedIn = true ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts < 3 ∧ a.failedAttempts + 1 = a.failedAttempts) ∧
              (o.signedIn = false ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts = 3 ∧ a.failedAttempts + 1 = a.failedAttempts) }.pre
      { accounts := [{ username := "sam", password := "wrong", failedAttempts := 2 }], username := "sam",
        password := "wrong" } ∧
    { pre := fun i => i.username ≠ "" ∧ i.password ≠ "",
          post := fun i o =>
            (o.signedIn = true ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts < 3 ∧ a.failedAttempts + 1 = a.failedAttempts) ∧
              (o.signedIn = false ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts = 3 ∧ a.failedAttempts + 1 = a.failedAttempts) }.post
      { accounts := [{ username := "sam", password := "wrong", failedAttempts := 3, lastAttempt := 1 }],
        username := "sam", password := "wrong" }
      { signedIn := false }
is false
```

**Error 2** — line 40:10 · duplicate declaration (harness joined 2 code blocks)

```lean
 40 | structure Account where
```

```text
`Account` has already been declared
```

**Error 3** — line 47:10 · duplicate declaration (harness joined 2 code blocks)

```lean
 47 | structure Input where
```

```text
`Input` has already been declared
```

**Error 4** — line 53:10 · duplicate declaration (harness joined 2 code blocks)

```lean
 53 | structure Output where
```

```text
`Output` has already been declared
```

**Error 5** — line 57:4 · duplicate declaration (harness joined 2 code blocks)

```lean
 57 | def Spec : Contract Input Output where
```

```text
`Spec` has already been declared
```

**Error 6** — line 71:15 · example false / decide failed

```lean
 71 |   unfold Spec; decide
```

```text
Tactic `decide` proved that the proposition
  { pre := fun i => i.username ≠ "" ∧ i.password ≠ "",
          post := fun i o =>
            (o.signedIn = true ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts < 3 ∧ a.failedAttempts + 1 = a.failedAttempts) ∧
              (o.signedIn = false ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts = 3 ∧ a.failedAttempts + 1 = a.failedAttempts) }.pre
      { accounts := [{ username := "sam", password := "wrong", failedAttempts := 2 }], username := "sam",
        password := "wrong" } ∧
    { pre := fun i => i.username ≠ "" ∧ i.password ≠ "",
          post := fun i o =>
            (o.signedIn = true ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts < 3 ∧ a.failedAttempts + 1 = a.failedAttempts) ∧
              (o.signedIn = false ↔
                ∃ a,
                  a ∈ i.accounts ∧
                    a.username = i.username ∧
                      a.password ≠ i.password ∧ a.failedAttempts = 3 ∧ a.failedAttempts + 1 = a.failedAttempts) }.post
      { accounts := [{ username := "sam", password := "wrong", failedAttempts := 3, lastAttempt := 1 }],
        username := "sam", password := "wrong" }
      { signedIn := false }
is false
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- 5.3/R5: The system shall detect consecutive failed login attempts.
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Account where
  8 |   username : String
  9 |   password : String
 10 |   failedAttempts : Nat := 0
 11 |   lastAttempt : Nat := 0
 12 |   deriving DecidableEq, Repr
 13 | 
 14 | structure Input where
 15 |   accounts : List Account
 16 |   username : String
 17 |   password : String
 18 |   deriving DecidableEq, Repr
 19 | 
 20 | structure Output where
 21 |   signedIn : Bool
 22 |   deriving DecidableEq, Repr
 23 | 
 24 | def Spec : Contract Input Output where
 25 |   pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
 26 |   post := fun i o => (o.signedIn = true ↔
 27 |     ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
 28 |     a.failedAttempts < 3 ∧ (a.failedAttempts + 1) = a.failedAttempts) ∧
 29 |     (o.signedIn = false ↔
 30 |     ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
 31 |     a.failedAttempts = 3 ∧ (a.failedAttempts + 1) = a.failedAttempts)
 32 | 
 33 | example : Spec.pre { accounts := [{ username := "sam", password := "wrong", failedAttempts := 2, lastAttempt := 0 }],
 34 |                      username := "sam", password := "wrong" } ∧
 35 |           Spec.post { accounts := [{ username := "sam", password := "wrong", failedAttempts := 3, lastAttempt := 1 }],
 36 |                       username := "sam", password := "wrong" }
 37 |                     { signedIn := false } := by
 38 |   unfold Spec; decide
 39 | 
 40 | structure Account where
 41 |   username : String
 42 |   password : String
 43 |   failedAttempts : Nat := 0
 44 |   lastAttempt : Nat := 0
 45 |   deriving DecidableEq, Repr
 46 | 
 47 | structure Input where
 48 |   accounts : List Account
 49 |   username : String
 50 |   password : String
 51 |   deriving DecidableEq, Repr
 52 | 
 53 | structure Output where
 54 |   signedIn : Bool
 55 |   deriving DecidableEq, Repr
 56 | 
 57 | def Spec : Contract Input Output where
 58 |   pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
 59 |   post := fun i o => (o.signedIn = true ↔
 60 |     ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
 61 |     a.failedAttempts < 3 ∧ (a.failedAttempts + 1) = a.failedAttempts) ∧
 62 |     (o.signedIn = false ↔
 63 |     ∃ a ∈ i.accounts, a.username = i.username ∧ a.password ≠ i.password ∧
 64 |     a.failedAttempts = 3 ∧ (a.failedAttempts + 1) = a.failedAttempts)
 65 | 
 66 | example : Spec.pre { accounts := [{ username := "sam", password := "wrong", failedAttempts := 2, lastAttempt := 0 }],
 67 |                      username := "sam", password := "wrong" } ∧
 68 |           Spec.post { accounts := [{ username := "sam", password := "wrong", failedAttempts := 3, lastAttempt := 1 }],
 69 |                       username := "sam", password := "wrong" }
 70 |                     { signedIn := false } := by
 71 |   unfold Spec; decide
```

</details>

### ❌ `5.5/R1` (requirement)

> The system shall perform searches via Dijkstra's shortest path algorithm.

**Error 1** — line 25:31 · not a function

```lean
 25 |                       o.cost = o.path.sum (·.3))
```

```text
Function expected at
  o.path.sum
but this term has type
  Nat

Note: Expected a function because this term is being applied to the argument
  (·.3)
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Input where
  8 |   startNode : Nat
  9 |   endNode   : Nat
 10 |   graph     : List (Nat × Nat × Nat)
 11 |   deriving DecidableEq, Repr
 12 | 
 13 | structure Output where
 14 |   path : List Nat
 15 |   cost : Nat
 16 |   deriving DecidableEq, Repr
 17 | 
 18 | -- IMPL: Dijkstra
 19 | 
 20 | def Spec : Contract Input Output where
 21 |   pre  := fun i => i.startNode < i.endNode ∧ i.graph.Nodup
 22 |   post := fun i o => (o.path = [] ↔ i.startNode = i.endNode) ∧
 23 |                      (o.path ≠ [] → o.path.contains i.startNode ∧
 24 |                       o.path.contains i.endNode ∧
 25 |                       o.cost = o.path.sum (·.3))
 26 | 
 27 | example : Spec.pre { startNode := 1, endNode := 4, graph := [(1, 2, 5), (2, 3, 2), (3, 4, 3)] } ∧
 28 |           Spec.post { startNode := 1, endNode := 4, graph := [(1, 2, 5), (2, 3, 2), (3, 4, 3)] }
 29 |                     { path := [1, 2, 3, 4], cost := 10 } := by
 30 |   unfold Spec; decide
```

</details>

### ❌ `5.5/R5` (requirement)

> The system shall validate email address existence.

**Error 1** — line 18:23 · type mismatch

```lean
 18 |     i.email.toList.all (·.isAlpha ∨ ·.isDigit ∨ · = '@' ∨ · = '.') = true
```

```text
Application type mismatch: The argument
  fun x1 x2 x3 x4 => x1.isAlpha = true ∨ ?m.13 ∨ x3 = '@' ∨ x4 = '.'
has type
  (x1 : Char) → ?m.16 x1 → Char → Char → Prop
but is expected to have type
  Char → Bool
in the application
  i.email.toList.all fun x1 x2 x3 x4 => x1.isAlpha = true ∨ ?m.13 ∨ x3 = '@' ∨ x4 = '.'
```

**Error 2** — line 18:36 · unknown field / invented API · `lean.invalidField`

```lean
 18 |     i.email.toList.all (·.isAlpha ∨ ·.isDigit ∨ · = '@' ∨ · = '.') = true
```

```text
Invalid field notation: Type of
  x2✝
is not known; cannot resolve field `isDigit`

Hint: Consider replacing the field projection `.isDigit` with a call to the function `Char.isDigit`.
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- 5.5/R5: The system shall validate email address existence.
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Input where
  8 |   email : String
  9 |   deriving DecidableEq, Repr
 10 | 
 11 | structure Output where
 12 |   exists_ : Bool
 13 |   deriving DecidableEq, Repr
 14 | 
 15 | def Spec : Contract Input Output where
 16 |   pre  := fun i => i.email ≠ ""
 17 |   post := fun i o => o.exists_ = true ↔
 18 |     i.email.toList.all (·.isAlpha ∨ ·.isDigit ∨ · = '@' ∨ · = '.') = true
 19 | 
 20 | example : Spec.pre { email := "test@example.com" } ∧
 21 |           Spec.post { email := "test@example.com" }
 22 |                     { exists_ := true } := by
 23 |   unfold Spec; decide
```

</details>

### ❌ `DD-credit-card-expiry-date` (data_constraint)

> The date on the credit card when it will get expired; format MM/YY

**Error 1** — line 20:26 · missing instance · `lean.synthInstanceFailed`

```lean
 20 |      i.raw.toList.Sublist 0 2 .all (fun c => c.isDigit) = true ∧
```

```text
failed to synthesize instance of type class
  OfNat (List Char) 0
numerals are polymorphic in Lean, but the numeral `0` cannot be used in a context where the expected type is
  List Char
due to the absence of the instance above

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

**Error 2** — line 21:26 · missing instance · `lean.synthInstanceFailed`

```lean
 21 |      i.raw.toList.Sublist 3 2 .all (fun c => c.isDigit) = true)
```

```text
failed to synthesize instance of type class
  OfNat (List Char) 3
numerals are polymorphic in Lean, but the numeral `3` cannot be used in a context where the expected type is
  List Char
due to the absence of the instance above

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

**Error 3** — line 28:10 · duplicate declaration (harness joined 2 code blocks)

```lean
 28 | structure Input where
```

```text
`Input` has already been declared
```

**Error 4** — line 32:10 · duplicate declaration (harness joined 2 code blocks)

```lean
 32 | structure Output where
```

```text
`Output` has already been declared
```

**Error 5** — line 36:4 · duplicate declaration (harness joined 2 code blocks)

```lean
 36 | def Spec : Contract Input Output where
```

```text
`Spec` has already been declared
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- DD-credit-card-expiry-date: The date on the credit card when it will get expired; format MM/YY
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Input where
  8 |   raw : String
  9 |   deriving DecidableEq, Repr
 10 | 
 11 | structure Output where
 12 |   valid : Bool
 13 |   deriving DecidableEq, Repr
 14 | 
 15 | def Spec : Contract Input Output where
 16 |   pre  := fun _ => True
 17 |   post := fun i o => o.valid = true ↔
 18 |     (i.raw.length = 5 ∧
 19 |      i.raw.toList.all (fun c => c.isDigit) = true ∧
 20 |      i.raw.toList.Sublist 0 2 .all (fun c => c.isDigit) = true ∧
 21 |      i.raw.toList.Sublist 3 2 .all (fun c => c.isDigit) = true)
 22 | 
 23 | example : Spec.pre { raw := "12/23" } ∧
 24 |           Spec.post { raw := "12/23" }
 25 |                     { valid := true } := by
 26 |   unfold Spec; decide
 27 | 
 28 | structure Input where
 29 |   raw : String
 30 |   deriving DecidableEq, Repr
 31 | 
 32 | structure Output where
 33 |   valid : Bool
 34 |   deriving DecidableEq, Repr
 35 | 
 36 | def Spec : Contract Input Output where
 37 |   pre  := fun _ => True
 38 |   post := fun i o => o.valid = true ↔
 39 |     (i.raw.length = 5 ∧
 40 |      i.raw.toList.all (fun c => c.isDigit) = true ∧
 41 |      i.raw.slice 0 2 .toList.all (fun c => c.isDigit) = true ∧
 42 |      i.raw.slice 3 2 .toList.all (fun c => c.isDigit) = true)
 43 | 
 44 | example : Spec.pre { raw := "12/23" } ∧
 45 |           Spec.post { raw := "12/23" }
 46 |                     { valid := true } := by
 47 |   unfold Spec; decide
```

</details>

### ❌ `DD-location` (data_constraint)

> Place where the item is kept in the warehouse in the form of (aisle, column, shelf)

**Error 1** — line 20:18 · unknown field / invented API · `lean.invalidField`

```lean
 20 |      i.raw.toList.nth? 0 ≠ none ∧
```

```text
Invalid field `nth?`: The environment does not contain `List.nth?`, so it is not possible to project the field `nth?` from an expression
  i.raw.toList
of type `List Char`
```

**Error 2** — line 21:18 · unknown field / invented API · `lean.invalidField`

```lean
 21 |      i.raw.toList.nth? 1 ≠ none ∧
```

```text
Invalid field `nth?`: The environment does not contain `List.nth?`, so it is not possible to project the field `nth?` from an expression
  i.raw.toList
of type `List Char`
```

**Error 3** — line 22:18 · unknown field / invented API · `lean.invalidField`

```lean
 22 |      i.raw.toList.nth? 2 ≠ none ∧
```

```text
Invalid field `nth?`: The environment does not contain `List.nth?`, so it is not possible to project the field `nth?` from an expression
  i.raw.toList
of type `List Char`
```

**Error 4** — line 23:19 · unknown field / invented API · `lean.invalidField`

```lean
 23 |      (i.raw.toList.nth? 0).get.isDigit = true ∧
```

```text
Invalid field `nth?`: The environment does not contain `List.nth?`, so it is not possible to project the field `nth?` from an expression
  i.raw.toList
of type `List Char`
```

**Error 5** — line 24:19 · unknown field / invented API · `lean.invalidField`

```lean
 24 |      (i.raw.toList.nth? 1).get.isDigit = true ∧
```

```text
Invalid field `nth?`: The environment does not contain `List.nth?`, so it is not possible to project the field `nth?` from an expression
  i.raw.toList
of type `List Char`
```

**Error 6** — line 25:19 · unknown field / invented API · `lean.invalidField`

```lean
 25 |      (i.raw.toList.nth? 2).get.isDigit = true)
```

```text
Invalid field `nth?`: The environment does not contain `List.nth?`, so it is not possible to project the field `nth?` from an expression
  i.raw.toList
of type `List Char`
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- DD-location: Place where the item is kept in the warehouse in the form of (aisle, column, shelf)
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Input where
  8 |   raw : String
  9 |   deriving DecidableEq, Repr
 10 | 
 11 | structure Output where
 12 |   valid : Bool
 13 |   deriving DecidableEq, Repr
 14 | 
 15 | def Spec : Contract Input Output where
 16 |   pre  := fun _ => True
 17 |   post := fun i o => o.valid = true ↔
 18 |     (i.raw.length = 3 ∧
 19 |      i.raw.toList.all (fun c => c = ' ' ∨ c.isDigit) = true ∧
 20 |      i.raw.toList.nth? 0 ≠ none ∧
 21 |      i.raw.toList.nth? 1 ≠ none ∧
 22 |      i.raw.toList.nth? 2 ≠ none ∧
 23 |      (i.raw.toList.nth? 0).get.isDigit = true ∧
 24 |      (i.raw.toList.nth? 1).get.isDigit = true ∧
 25 |      (i.raw.toList.nth? 2).get.isDigit = true)
 26 | 
 27 | example : Spec.pre { raw := "1 2 3" } ∧
 28 |           Spec.post { raw := "1 2 3" }
 29 |                     { valid := true } := by
 30 |   unfold Spec; decide
```

</details>

### ❌ `DD-shipping-date` (data_constraint)

> Date when the specified order is shipped; format MM/DD/YYYY

**Error 1** — line 20:11 · unknown field / invented API · `lean.invalidField`

```lean
 20 |      i.raw.substring 0 2 .toNat ≤ 12 ∧
```

```text
Invalid field `substring`: The environment does not contain `String.substring`, so it is not possible to project the field `substring` from an expression
  i.raw
of type `String`
```

**Error 2** — line 21:11 · unknown field / invented API · `lean.invalidField`

```lean
 21 |      i.raw.substring 3 5 .toNat ≤ 31 ∧
```

```text
Invalid field `substring`: The environment does not contain `String.substring`, so it is not possible to project the field `substring` from an expression
  i.raw
of type `String`
```

**Error 3** — line 22:11 · unknown field / invented API · `lean.invalidField`

```lean
 22 |      i.raw.substring 6 8 .toNat ≤ 99)
```

```text
Invalid field `substring`: The environment does not contain `String.substring`, so it is not possible to project the field `substring` from an expression
  i.raw
of type `String`
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- DD-shipping-date: Date when the specified order is shipped; format MM/DD/YYYY
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Input where
  8 |   raw : String
  9 |   deriving DecidableEq, Repr
 10 | 
 11 | structure Output where
 12 |   valid : Bool
 13 |   deriving DecidableEq, Repr
 14 | 
 15 | def Spec : Contract Input Output where
 16 |   pre  := fun _ => True
 17 |   post := fun i o => o.valid = true ↔
 18 |     (i.raw.length = 10 ∧
 19 |      i.raw.toList.all (fun c => c == ' ' ∨ c.isDigit) = true ∧
 20 |      i.raw.substring 0 2 .toNat ≤ 12 ∧
 21 |      i.raw.substring 3 5 .toNat ≤ 31 ∧
 22 |      i.raw.substring 6 8 .toNat ≤ 99)
 23 | 
 24 | example : Spec.pre { raw := "12/31/99" } ∧
 25 |           Spec.post { raw := "12/31/99" }
 26 |                     { valid := true } := by
 27 |   unfold Spec; decide
```

</details>

### ❌ `UC-administrator-change-user-properties` (use_case)

> Change User Properties: Alter properties such as passwords and privileges of the user.

**Error 1** — line 33:12 · unknown field / invented API · `lean.invalidField`

```lean
 33 |     o.users.nodup ∧
```

```text
Invalid field `nodup`: The environment does not contain `List.nodup`, so it is not possible to project the field `nodup` from an expression
  o.users
of type `List User`
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure User where
  8 |   username : String
  9 |   password : String
 10 |   privileges : Nat
 11 |   deriving DecidableEq, Repr
 12 | 
 13 | structure Input where
 14 |   users : List User
 15 |   targetUsername : String
 16 |   newPassword : String
 17 |   newPrivileges : Nat
 18 |   deriving DecidableEq, Repr
 19 | 
 20 | structure Output where
 21 |   users : List User
 22 |   deriving DecidableEq, Repr
 23 | 
 24 | def Spec : Contract Input Output where
 25 |   pre  := fun i => i.targetUsername ≠ "" ∧
 26 |                    ∃ u ∈ i.users, u.username = i.targetUsername
 27 |   post := fun i o => o.users = i.users.map (fun u => 
 28 |     if u.username = i.targetUsername then
 29 |       { username := u.username, password := i.newPassword, privileges := i.newPrivileges }
 30 |     else
 31 |       u
 32 |   ) ∧
 33 |     o.users.nodup ∧
 34 |     ∃ u ∈ o.users, u.username = i.targetUsername ∧ u.password = i.newPassword ∧ u.privileges = i.newPrivileges
 35 | 
 36 | example : Spec.pre { users := [{ username := "john", password := "pass1", privileges := 2 }],
 37 |                      targetUsername := "john", newPassword := "newpass", newPrivileges := 3 } ∧
 38 |           Spec.post { users := [{ username := "john", password := "newpass", privileges := 3 }],
 39 |                       targetUsername := "john", newPassword := "newpass", newPrivileges := 3 }
 40 |                     { users := [{ username := "john", password := "newpass", privileges := 3 }] } := by
 41 |   unfold Spec; decide
```

</details>

### ❌ `UC-customer-add-item-to-cart` (use_case)

> Add Item To Cart: Customer adds item(s) in the cart

**Error 1** — line 28:10 · type mismatch

```lean
 28 |           Spec.post { signedIn := true, cart := ["item1", "item2"], done := true } := by
```

```text
Application type mismatch: The argument
  Spec.post { signedIn := true, cart := ["item1", "item2"], done := true }
has type
  Output → Prop
but is expected to have type
  Prop
in the application
  Spec.pre { signedIn := true, cart := ["item1", "item2"], done := false } ∧
    Spec.post { signedIn := true, cart := ["item1", "item2"], done := true }
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Input where
  8 |   signedIn : Bool
  9 |   cart     : List String
 10 |   done     : Bool
 11 |   deriving DecidableEq, Repr
 12 | 
 13 | structure Output where
 14 |   signedIn : Bool
 15 |   cart     : List String
 16 |   done     : Bool
 17 |   deriving DecidableEq, Repr
 18 | 
 19 | def Spec : Contract Input Output where
 20 |   pre  := fun i => i.signedIn = true
 21 |   post := fun i o => (o.done = true ↔
 22 |     i.cart = o.cart) ∧
 23 |                      (o.signedIn = i.signedIn) ∧
 24 |                      (o.done = false →
 25 |                       ∃ s ∈ i.cart, s ≠ "")
 26 | 
 27 | example : Spec.pre { signedIn := true, cart := ["item1", "item2"], done := false } ∧
 28 |           Spec.post { signedIn := true, cart := ["item1", "item2"], done := true } := by
 29 |   unfold Spec; decide
```

</details>

### ❌ `UC-customer-login-customer` (use_case)

> Login Customer: Login to a customer account with the system.

**Error 1** — line 27:60 · unknown field / invented API · `lean.invalidField`

```lean
 27 |       (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 1 ∧
```

```text
Invalid field `map`: The environment does not contain `Function.map`, so it is not possible to project the field `map` from an expression
  fun a => ?m.19 = i.username
of type `?m.17 → Prop`
```

**Error 2** — line 29:60 · unknown field / invented API · `lean.invalidField`

```lean
 29 |       (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 0 ∧
```

```text
Invalid field `map`: The environment does not contain `Function.map`, so it is not possible to project the field `map` from an expression
  fun a => ?m.31 = i.username
of type `?m.29 → Prop`
```

**Error 3** — line 27:35 · unknown field / invented API · `lean.invalidField`

```lean
 27 |       (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 1 ∧
```

```text
Invalid field notation: Type of
  a
is not known; cannot resolve field `username`

Hint: Consider replacing the field projection with a call to one of the following:
  • `Account.username`
  • `Input.username`
```

**Error 4** — line 29:35 · unknown field / invented API · `lean.invalidField`

```lean
 29 |       (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 0 ∧
```

```text
Invalid field notation: Type of
  a
is not known; cannot resolve field `username`

Hint: Consider replacing the field projection with a call to one of the following:
  • `Account.username`
  • `Input.username`
```

<details><summary>Full file</summary>

```lean
  1 | import ContractForge
  2 | open ContractForge
  3 | 
  4 | -- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
  5 | -- compiles: False · rejects_bad_example: None · checked: False
  6 | 
  7 | structure Account where
  8 |   username : String
  9 |   password : String
 10 |   email    : String
 11 |   deriving DecidableEq, Repr
 12 | 
 13 | structure Input where
 14 |   accounts : List Account
 15 |   username : String
 16 |   password : String
 17 |   deriving DecidableEq, Repr
 18 | 
 19 | structure Output where
 20 |   signedIn : Bool
 21 |   deriving DecidableEq, Repr
 22 | 
 23 | def Spec : Contract Input Output where
 24 |   pre  := fun i => i.accounts.any (fun a => a.username = i.username ∧ a.password = i.password)
 25 |   post := fun i o => o.signedIn = true ↔
 26 |     (i.accounts.any (fun a => a.username = i.username ∧ a.password = i.password) →
 27 |       (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 1 ∧
 28 |        o.signedIn = true) ∨
 29 |       (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 0 ∧
 30 |        o.signedIn = true))
 31 | 
 32 | example : Spec.pre { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }],
 33 |                      username := "john", password := "pass123" } ∧
 34 |           Spec.post { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }],
 35 |                       username := "john", password := "pass123" }
 36 |                     { signedIn := true } := by
 37 |   unfold Spec; decide
```

</details>

