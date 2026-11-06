import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: False · rejects_bad_example: None · checked: False

structure CreditCard where
  number : String
  expMonth : Nat
  expYear : Nat
  cvv : Nat
  deriving DecidableEq, Repr

structure Input where
  creditCard : Option CreditCard
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  creditCard : Option CreditCard
  failedAttempts : Nat
  validated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.creditCard ≠ none
  post := fun i o => o.creditCard = i.creditCard ∧
                     o.failedAttempts = i.failedAttempts + 1 ∧
                     (o.validated = true ↔
                      o.creditCard.isSome ∧
                      o.creditCard.getD { number := "", expMonth := 0, expYear := 0, cvv := 0 }.expMonth ≤ 12 ∧
                      o.creditCard.getD { number := "", expMonth := 0, expYear := 0, cvv := 0 }.expYear ≥ 2023)

example : Spec.pre { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 2023, cvv := 123 },
                     failedAttempts := 0 } ∧
          Spec.post { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 2023, cvv := 123 },
                      failedAttempts := 0 }
                    { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 2023, cvv := 123 },
                      failedAttempts := 1, validated := true } := by
  unfold Spec; decide
