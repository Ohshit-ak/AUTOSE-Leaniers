-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- checked: True

structure Input where
  username : String
  password : String

structure Output where
  logged_in : Bool
  session_cookie : Option String

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.logged_in = true ∧ o.session_cookie ≠ none

example : Spec.pre ⟨"salesperson", "password123"⟩ ∧ Spec.post ⟨"salesperson", "password123"⟩ ⟨true, some "cookie12345"⟩ := by
  simp [Spec]
