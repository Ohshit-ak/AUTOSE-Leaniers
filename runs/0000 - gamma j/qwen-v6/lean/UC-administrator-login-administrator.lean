import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ↔
    (i.username = "admin" ∧ i.password = "admin123" ∧
     (o.cookie.isSome ↔ true) ∧
     (o.cookie.isNone ↔ false))

example : Spec.pre { username := "admin", password := "admin123" } ∧
          Spec.post { username := "admin", password := "admin123" }
                    { signedIn := true, cookie := some "admin-cookie" } := by
  unfold Spec; decide
