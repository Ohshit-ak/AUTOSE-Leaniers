import ContractForge
open ContractForge

-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system
-- compiles: True · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  role     : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  role     : String
  accounts : List Account
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.role ∈ ["customer", "sales person", "administrator"]
  post := fun i o => o.accounts = i.accounts ++ [{ username := i.username, password := i.password, role := i.role }]

example : Spec.pre { accounts := [],
                     username := "newuser", password := "pass123", role := "customer" } ∧
          Spec.post { accounts := [],
                      username := "newuser", password := "pass123", role := "customer" }
                    { accounts := [{ username := "newuser", password := "pass123", role := "customer" }] } := by
  unfold Spec; decide
