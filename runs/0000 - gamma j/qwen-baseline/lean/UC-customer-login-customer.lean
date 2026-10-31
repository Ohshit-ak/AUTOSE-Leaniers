-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- checked: True

structure Input where
  username : String
  password : String
  email    : String

structure Output where
  logged_in : Bool
  cookie    : Option String

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.logged_in = true ∧ o.cookie ≠ none

example : Spec.pre ⟨"user123", "pass456", "user@example.com"⟩ ∧ Spec.post ⟨"user123", "pass456", "user@example.com"⟩ ⟨true, some "cookie12345"⟩ := by
  simp [Spec]
