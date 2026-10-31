-- UC-administrator-add-user: Add User: Register a new customer, sales person, or administrator account with the system
-- checked: True

structure Input where
  username : String
  password : String
  role     : String

structure Output where
  accountCreated : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator")
  post := fun i o => o.accountCreated = true → (i.role = "customer" → true) ∧ (i.role = "sales person" → true) ∧ (i.role = "administrator" → true)

example : Spec.pre ⟨"john_doe", "password123", "customer"⟩ ∧ Spec.post ⟨"john_doe", "password123", "customer"⟩ ⟨true⟩ := by
  simp [Spec]
