import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: True · rejects_bad_example: False · checked: False

structure Account where
  username : String
  password : String
  email    : String
  role     : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  role     : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  username : String
  role     : String
  session  : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.role = "Administrator"
  post := fun i o => o.role = "Administrator" ∧
                     (o.failedAttempts = i.failedAttempts + 1 ↔ i.password ≠ "correctPassword") ∧
                     (o.session ≠ "" ↔ i.failedAttempts < 3) ∧
                     (o.username = i.username)

example : Spec.pre { username := "admin", password := "incorrect", email := "admin@example.com",
                     role := "Administrator", failedAttempts := 0 } ∧
          Spec.post { username := "admin", password := "incorrect", email := "admin@example.com",
                      role := "Administrator", failedAttempts := 0 }
                    { username := "admin", role := "Administrator", session := "sessionCookie", failedAttempts := 1 } := by
  unfold Spec; decide
