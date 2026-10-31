-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system
-- checked: True

structure Input where
  role    : String
  info    : String
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  account  : String
  privileges : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator"
  post := fun i o => o.accepted = true ∧
                     o.account.length > 0 ∧
                     o.privileges = i.role

example : Spec.pre { role := "customer", info := "John Doe" } ∧
          Spec.post { role := "customer", info := "John Doe" }
                     { accepted := true, account := "cust123", privileges := "customer" } := by
  unfold Spec; decide
