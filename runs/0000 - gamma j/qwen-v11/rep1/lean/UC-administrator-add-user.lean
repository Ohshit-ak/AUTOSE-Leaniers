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
  privileges : String
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  role     : String
  privileges : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                 (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
                 (i.privileges = "read" ∨ i.role = "customer")
  post := fun i o => o.username = i.username ∧ o.password = i.password ∧
                     (o.role = i.role ∧ o.privileges = "read" ∨
                      o.role = "customer" ∧ o.privileges = i.privileges)

example : Spec.pre { username := "newuser", password := "pass123", role := "customer", privileges := "read" } ∧
          Spec.post { username := "newuser", password := "pass123", role := "customer", privileges := "read" }
                    { username := "newuser", password := "pass123", role := "customer", privileges := "read" } := by
  unfold Spec; decide
