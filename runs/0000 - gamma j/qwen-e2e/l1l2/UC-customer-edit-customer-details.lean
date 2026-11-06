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

-- L1 architect (success=False)

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

-- Decompose the spec into two components

def UpdateUsernameContract : Contract Input Output := 
  { pre  := fun i => i.signedIn = true
  , post := fun i o => o.signedIn = i.signedIn ∧
                       o.changes.username = i.changes.username
  }

def UpdatePasswordEmailPhoneContract : Contract Input Output := 
  { pre  := fun i => i.signedIn = true
  , post := fun i o => o.signedIn = i.signedIn ∧
                       o.changes.password = i.changes.password ∧
                       o.changes.email = i.changes.email ∧
                       o.changes.phone = i.changes.phone
  }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_UpdateUsername : Contract.Compatible UpdateUsernameContract Spec := 
  by
    intro i o
    simp [UpdateUsernameContract, Spec]
    split
    { assumption }
    { assumption }

theorem PO1_UpdatePasswordEmailPhone : Contract.Compatible UpdatePasswordEmailPhoneContract UpdateUsernameContract := 
  by
    intro i o
    simp [UpdatePasswordEmailPhoneContract, UpdateUsernameContract]
    split
    { assumption }
    { assumption }

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (UpdateUsernameContract.seq UpdatePasswordEmailPhoneContract) Spec := 
  by
    intro i o
    simp [UpdateUsernameContract, UpdatePasswordEmailPhoneContract, Spec]
    split
    { assumption }
    { assumption }

-- Discharge the proof obligations
discharge_po