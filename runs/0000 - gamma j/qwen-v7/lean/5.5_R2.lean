import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: True · rejects_bad_example: None · checked: False

structure CreditCard where
  cardNumber : String
  expiryDate : String
  cvv        : Nat
  deriving DecidableEq, Repr

structure Input where
  existingCards : List CreditCard
  cardNumber    : String
  expiryDate    : String
  cvv          : Nat
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  validCard : Bool
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < 3
  post := fun i o => o.validCard ↔
    ∃ c ∈ i.existingCards, c.cardNumber = i.cardNumber ∧
                           c.expiryDate = i.expiryDate ∧
                           c.cvv = i.cvv ∧
    o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { existingCards := [{ cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123 }],
                     cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123, failedAttempts := 2 } ∧
          Spec.post { existingCards := [{ cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123 }],
                      cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123, failedAttempts := 2 }
                    { validCard := true, failedAttempts := 3 } := by
  unfold Spec; decide
