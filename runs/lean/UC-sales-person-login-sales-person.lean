-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- checked: None

structure Contract (Input Output) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure Input where
  username : String
  password : String
  email    : String

structure Output where
  sessionCookie : String

def Spec : Contract Input Output :=
  { pre := λ i, i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  , post := λ i o, o.sessionCookie ≠ "" }

example : Spec.pre { username := "salesperson123", password := "password123", email := "salesperson@example.com" } :=
  true

example : Spec.post { username := "salesperson123", password := "password123", email := "salesperson@example.com" } { sessionCookie := "abc123" } :=
  true
