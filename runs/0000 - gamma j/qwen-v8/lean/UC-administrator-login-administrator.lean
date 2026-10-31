import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ∧
                     (o.cookie ≠ "" ↔ i.username = "admin" ∧ i.password = "admin123")

example : Spec.pre { username := "admin", password := "admin123" } ∧
          Spec.post { username := "admin", password := "admin123" }
                    { signedIn := true, cookie := "abc123" } := by
  unfold Spec; decide
