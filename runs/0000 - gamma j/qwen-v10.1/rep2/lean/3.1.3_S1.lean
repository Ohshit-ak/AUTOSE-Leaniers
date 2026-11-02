import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  email    : String
  history  : List String
  confirmed : Bool
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  history  : List String
  confirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  username : String
  email    : String
  history  : List String
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.username = i.username ∧
                     o.email = i.email ∧
                     o.history = i.history ∧
                     o.confirmed = i.confirmed

example : Spec.pre { username := "john", password := "pass123", email := "john@example.com", history := [], confirmed := false } ∧
          Spec.post { username := "john", password := "pass123", email := "john@example.com", history := [], confirmed := false }
                    { username := "john", email := "john@example.com", history := [], confirmed := false } := by
  unfold Spec; decide
