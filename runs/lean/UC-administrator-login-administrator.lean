-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- checked: None

structure Contract (Input Output) where
  pre : Input → Prop
  post : Input → Output → Prop

structure Input where
  username : String
  password : String
  email    : String

structure Output where
  sessionCookie : String

def Spec : Contract Input Output :=
  { pre := λ i, i.username = "admin" ∧ i.password = "admin" ∧ i.email = "admin@example.com"
  , post := λ i o, o.sessionCookie ≠ "" }

example : Spec.pre { username := "admin", password := "admin", email := "admin@example.com" } :=
  true

example : Spec.post { username := "admin", password := "admin", email := "admin@example.com" } { sessionCookie := "abc123" } :=
  true
