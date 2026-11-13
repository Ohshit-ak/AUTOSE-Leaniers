import ContractForge
open ContractForge

-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.

-- L0 spec

structure Account where
  username : String
  password : String
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
                     o.changes.username = i.changes.username ∧
                     o.changes.password = i.changes.password ∧
                     o.changes.email = i.changes.email ∧
                     o.changes.phone = i.changes.phone

example : Spec.pre { signedIn := true, changes := { username := "john", password := "pass123", email := "john@example.com", phone := "1234567890" } } ∧
          Spec.post { signedIn := true, changes := { username := "john", password := "pass123", email := "john@example.com", phone := "1234567890" } }
                    { signedIn := true, changes := { username := "john", password := "pass123", email := "john@example.com", phone := "1234567890" } } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  username : String
  password : String
  email    : String
  phone    : String
  deriving DecidableEq, Repr

def UpdateAccountContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.username = i.changes.username ∧
                     m.password = i.changes.password ∧
                     m.email = i.changes.email ∧
                     m.phone = i.changes.phone

def ApplyChangesContract : Contract Mid Output where
  pre  := fun m => true
  post := fun m o => o.signedIn = m.signedIn ∧
                     o.changes.username = m.username ∧
                     o.changes.password = m.password ∧
                     o.changes.email = m.email ∧
                     o.changes.phone = m.phone
