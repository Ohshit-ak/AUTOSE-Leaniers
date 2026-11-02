import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  logged_in : Bool
  accounts : List Account
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.logged_in = true ↔ i.logged_in = false ∧
                      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
                     (o.logged_in = false ↔ i.logged_in = false ∧
                      ∀ a ∈ i.accounts, a.username ≠ i.username ∨ a.password ≠ i.password)

example : Spec.pre { username := "testuser", password := "wrongpassword", logged_in := false, accounts := [{ username := "testuser", password := "correctpassword" }] } ∧ Spec.post { username := "testuser", password := "wrongpassword", logged_in := false, accounts := [{ username := "testuser", password := "correctpassword" }] } { logged_in := false } := by
  unfold Spec; decide
