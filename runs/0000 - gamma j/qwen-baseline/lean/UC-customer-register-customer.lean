-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- checked: False

structure Input where
  customerInfo : String
  cookie       : String

structure Output where
  accountCreated : Bool
  sessionCookie  : String

def Spec : Contract Input Output where
  pre  := fun i => i.customerInfo ≠ "" ∧ i.cookie = ""
  post := fun i o => o.accountCreated = true ∧ o.sessionCookie ≠ ""

example : Spec.pre ⟨"John Doe", ""⟩ ∧ Spec.post ⟨"John Doe", true, "cookie123"⟩ := by
  simp [Spec]
