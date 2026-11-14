import ContractForge
open ContractForge

-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.

-- L0 spec

structure Account where
  username : String
  email    : String
  phone    : String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  changes  : Account
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  changes  : Account
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     (o.changes.username = i.changes.username ↔ i.changes.username ≠ "") ∧
                     (o.changes.email = i.changes.email ↔ i.changes.email ≠ "") ∧
                     (o.changes.phone = i.changes.phone ↔ i.changes.phone ≠ "")

example : Spec.pre { signedIn := true, changes := { username := "john", email := "john@example.com", phone := "1234567890" } } ∧
          Spec.post { signedIn := true, changes := { username := "john", email := "john@example.com", phone := "1234567890" } }
                    { signedIn := true, changes := { username := "john", email := "john@example.com", phone := "1234567890" } } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { signedIn := x.signedIn,
    changes := { username := if x.changes.username ≠ "" then x.changes.username else "", 
                  email := if x.changes.email ≠ "" then x.changes.email else "", 
                  phone := if x.changes.phone ≠ "" then x.changes.phone else "" } }
