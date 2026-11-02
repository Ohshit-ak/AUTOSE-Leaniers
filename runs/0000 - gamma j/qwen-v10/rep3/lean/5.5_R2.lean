import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  cardNumber : String
  expiryDate : String
  cvv        : Nat
  deriving DecidableEq, Repr

structure Input where
  loggedIn : Bool
  failedAttempts : Nat
  creditCards : List CreditCard
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  failedAttempts : Nat
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.loggedIn = true
  post := fun i o => o.loggedIn = i.loggedIn ∧
                     o.failedAttempts = i.failedAttempts + 1 ∧
                     (o.accepted = true ↔
                      ∃ cc ∈ i.creditCards, cc.cardNumber = "existing" ∧
                      (cc.expiryDate = "MM/YY" ∨ cc.expiryDate = "MM/DD/YYYY"))

example : Spec.pre { loggedIn := true, failedAttempts := 0, creditCards := [{ cardNumber := "existing", expiryDate := "MM/YY", cvv := 123 }] } ∧
          Spec.post { loggedIn := true, failedAttempts := 0, creditCards := [{ cardNumber := "existing", expiryDate := "MM/YY", cvv := 123 }] }
                    { loggedIn := true, failedAttempts := 1, accepted := true } := by
  unfold Spec; decide
