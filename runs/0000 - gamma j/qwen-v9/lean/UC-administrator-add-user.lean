import ContractForge
open ContractForge

-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  role     : String
  privileges : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  role     : String
  deriving DecidableEq, Repr

structure Output where
  account : Account
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                  (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator")
  post := fun i o => o.account.role = i.role ∧
                     (o.account.username = i.username ∧
                      o.account.password = i.password ∧
                      o.account.privileges = "basic")

example : Spec.pre { username := "john", password := "password123", role := "customer" } ∧
          Spec.post { username := "john", password := "password123", role := "customer" }
                    { account := { username := "john", password := "password123", role := "customer", privileges := "basic" } } := by
  unfold Spec; decide
