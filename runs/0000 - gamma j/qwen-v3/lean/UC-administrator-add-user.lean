-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system
-- checked: True

structure Input where
  role      : String
  firstName : String
  lastName  : String
  email     : String
  password  : String
  deriving DecidableEq, Repr

structure Output where
  newAccount : String
  privileges : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator"
  post := fun i o => o.newAccount ≠ "" ∧
                     o.privileges = if i.role = "customer" then "read" else
                                    if i.role = "sales person" then "read, write" else
                                    if i.role = "administrator" then "read, write, manage" else ""

example : Spec.pre { role := "customer", firstName := "John", lastName := "Doe", email := "john.doe@example.com", password := "p@ssw0rd" } ∧
          Spec.post { role := "customer", firstName := "John", lastName := "Doe", email := "john.doe@example.com", password := "p@ssw0rd" }
                     { newAccount := "acc123", privileges := "read" } := by
  unfold Spec; decide
