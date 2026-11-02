import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  registeredAccounts : List Account
  username           : String
  password           : String
  logged_in          : Bool
  deriving DecidableEq, Repr

structure Output where
  logged_in          : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.logged_in = true ↔
    (i.logged_in = false ∧
     ∃ a ∈ i.registeredAccounts, a.username = i.username ∧ a.password = i.password) ∨
    (i.logged_in = true ∧
     ∀ a ∈ i.registeredAccounts, a.username ≠ i.username)

example : Spec.pre { registeredAccounts := [{ username := "john", password := "pass123" }],
                     username := "john", password := "pass123", logged_in := false } ∧
          Spec.post { registeredAccounts := [{ username := "john", password := "pass123" }],
                      username := "john", password := "pass123", logged_in := false }
                    { logged_in := true } := by
  unfold Spec; decide

example : Spec.pre { registeredAccounts := [{ username := "john", password := "pass123" }],
                     username := "john", password := "pass123", logged_in := true } ∧
          Spec.post { registeredAccounts := [{ username := "john", password := "pass123" }],
                      username := "john", password := "pass123", logged_in := true }
                    { logged_in := false } := by
  unfold Spec; decide
