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
  isCustomer : Bool
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
                 i.isCustomer
  post := fun i o => (o.username = i.username ∧ o.password = i.password ∧
                      o.role = i.role ∧ o.privileges = i.privileges) ↔
                    (i.isCustomer ∧
                     o.username ≠ "" ∧ o.password ≠ "" ∧
                     o.role = "customer" ∧ o.privileges ≠ "")

example : Spec.pre { username := "newuser", password := "password123", role := "customer", privileges := "read", isCustomer := true } ∧
          Spec.post { username := "newuser", password := "password123", role := "customer", privileges := "read", isCustomer := true }
                    { username := "newuser", password := "password123", role := "customer", privileges := "read" } := by
  unfold Spec; decide
