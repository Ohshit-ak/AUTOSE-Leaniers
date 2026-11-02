import ContractForge
open ContractForge

-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  changes  : Account
  oldPassword : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  changes  : Account
  success  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => (o.success = true ↔
    i.oldPassword = i.changes.password) ∧
                     (o.success = false ↔
    i.signedIn = o.signedIn ∧
    i.changes.username = o.changes.username ∧
    i.changes.password = o.changes.password ∧
    i.changes.email = o.changes.email)

example : Spec.pre { signedIn := true, changes := { username := "newName", password := "correctPassword", email := "newEmail" }, oldPassword := "correctPassword" } ∧ Spec.post { signedIn := true, changes := { username := "newName", password := "correctPassword", email := "newEmail" }, oldPassword := "correctPassword" } { signedIn := false, changes := { username := "newName", password := "correctPassword", email := "newEmail" }, success := true } := by
  unfold Spec; decide
