-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- checked: True

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.logged = true ∧
                     (i.username = "salesperson" → o.cookie.isSome) ∧
                     (i.username ≠ "salesperson" → o.cookie.isNone)

example : Spec.pre { username := "salesperson", password := "password123" } ∧
          Spec.post { username := "salesperson", password := "password123" }
                    { logged := true, cookie := some 12345 } := by
  unfold Spec; decide
