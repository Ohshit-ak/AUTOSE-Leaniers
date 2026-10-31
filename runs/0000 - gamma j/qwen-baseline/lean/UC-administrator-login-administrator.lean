-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- checked: True

structure Input where
  username : String
  password : String
  email    : String

structure Output where
  logged_in : Bool
  session_cookie : Option String

def Spec : Contract Input Output where
  pre  := fun i => i.username = "admin" ∧ i.password = "admin" ∧ i.email = "admin@example.com"
  post := fun i o => o.logged_in = true ∧ o.session_cookie ≠ none

example : Spec.pre ⟨"admin", "admin", "admin@example.com"⟩ ∧ Spec.post ⟨"admin", "admin", "admin@example.com"⟩ ⟨true, some "cookie123"⟩ := by
  simp [Spec]
