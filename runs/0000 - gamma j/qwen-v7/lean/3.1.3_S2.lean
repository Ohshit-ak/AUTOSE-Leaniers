import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: True · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.logged_in = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
                     (o.logged_in = false ↔ ¬(∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password))

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }],
                     username := "sam", password := "pw1", logged_in := false } ∧
          Spec.post { accounts := [{ username := "sam", password := "pw1" }],
                      username := "sam", password := "pw1", logged_in := false }
                    { logged_in := true } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }],
                     username := "sam", password := "pw2", logged_in := false } ∧
          Spec.post { accounts := [{ username := "sam", password := "pw1" }],
                      username := "sam", password := "pw2", logged_in := false }
                    { logged_in := false } := by
  unfold Spec; decide
