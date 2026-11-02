import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => (o.signedIn = false ↔ i.signedIn = true) ∧
                     (o.cookie ≠ i.cookie ↔ i.signedIn = true)

example : Spec.pre { signedIn := true, cookie := "admin_cookie" } ∧
          Spec.post { signedIn := true, cookie := "admin_cookie" }
                    { signedIn := false, cookie := "new_cookie" } := by
  unfold Spec; decide
