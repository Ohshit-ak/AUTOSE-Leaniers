import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  account  : Account
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" -- Administrator account must be registered
  post := fun i o => (o.logged = true ↔ i.password = i.account.password) ∧
                     (o.logged = false → i.password ≠ i.account.password) ∧
                     (o.cookie ≠ "" ↔ o.logged = true)

example : Spec.pre { username := "admin", password := "pass", email := "admin@example.com", account := { username := "admin", password := "pass", email := "admin@example.com" } } ∧
          Spec.post { username := "admin", password := "pass", email := "admin@example.com", account := { username := "admin", password := "pass", email := "admin@example.com" } }
                    { logged := true, cookie := "abc123" } := by
  unfold Spec; decide

example : Spec.pre { username := "admin", password := "wrong", email := "admin@example.com", account := { username := "admin", password := "pass", email := "admin@example.com" } } ∧
          Spec.post { username := "admin", password := "wrong", email := "admin@example.com", account := { username := "admin", password := "pass", email := "admin@example.com" } }
                    { logged := false, cookie := "" } := by
  unfold Spec; decide
