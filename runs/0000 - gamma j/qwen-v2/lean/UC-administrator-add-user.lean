-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system
-- checked: True

structure Input where
  role    : String
  name    : String
  email   : String
  password: String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  account : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.role ∈ ["customer", "sales person", "administrator"]
  post := fun i o => o.success = true ∧
                     (o.account = "customer" ↔ i.role = "customer") ∧
                     o.account ≠ ""

example : Spec.pre { role := "customer", name := "John Doe", email := "john@example.com", password := "pass123" } ∧
          Spec.post { role := "customer", name := "John Doe", email := "john@example.com", password := "pass123" }
                    { success := true, account := "customer" } := by
  unfold Spec; decide
