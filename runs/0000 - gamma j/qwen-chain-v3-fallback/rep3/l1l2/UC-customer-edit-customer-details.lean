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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  username : String
  password : String
  email    : String
  phone    : String
  ok       : Bool
  deriving DecidableEq, Repr

def UpdateAccountContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.username = i.changes.username ∧
                     m.password = i.changes.password ∧
                     m.email = i.changes.email ∧
                     m.phone = i.changes.phone ∧
                     m.ok = true

def ApplyChangesContract : Contract Mid Output where
  pre  := fun m => m.ok = true
  post := fun m o => o.signedIn = true ∧
                     o.changes.username = m.username ∧
                     o.changes.password = m.password ∧
                     o.changes.email = m.email ∧
                     o.changes.phone = m.phone

theorem po1 : Contract.Compatible UpdateAccountContract ApplyChangesContract := by
  discharge_po1 [UpdateAccountContract, ApplyChangesContract, Spec]

theorem po2 : Contract.Refines (UpdateAccountContract.seq ApplyChangesContract) Spec := by
  discharge_po2 [UpdateAccountContract, ApplyChangesContract, Spec]

-- L2 UpdateAccountContract (success=True)

def UpdateAccountContractImpl (x : Input) : Mid :=
  { username := x.changes.username, password := x.changes.password, email := x.changes.email, phone := x.changes.phone, ok := true }

theorem UpdateAccountContractImpl_ok : UpdateAccountContract.Satisfies UpdateAccountContractImpl := by
  discharge_po3 [UpdateAccountContract, UpdateAccountContractImpl]

-- L2 ApplyChangesContract (success=True)

def ApplyChangesContractImpl (x : Mid) : Output :=
  { signedIn := true, changes := { username := x.username, password := x.password, email := x.email, phone := x.phone } }

theorem ApplyChangesContractImpl_ok : ApplyChangesContract.Satisfies ApplyChangesContractImpl := by
  discharge_po3 [ApplyChangesContract, ApplyChangesContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ApplyChangesContractImpl ∘ UpdateAccountContractImpl) :=
  Contract.system_sound po1 po2 UpdateAccountContractImpl_ok ApplyChangesContractImpl_ok
