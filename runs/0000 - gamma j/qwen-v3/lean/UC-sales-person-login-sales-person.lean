-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- checked: True

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ∧ o.cookie.isSome = true

example : Spec.pre { username := "salesperson", password := "password123" } ∧
          Spec.post { username := "salesperson", password := "password123" }
                    { signedIn := true, cookie := some 12345 } := by
  unfold Spec; decide
