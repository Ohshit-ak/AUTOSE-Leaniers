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
  existingCards : List CreditCard
  cardNumber    : String
  expiryDate    : String
  cvv           : Nat
  deriving DecidableEq, Repr

structure Output where
  validated     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cardNumber ≠ "" ∧ i.expiryDate ≠ "" ∧ 0 < i.cvv
  post := fun i o => o.validated = true ↔
    ∃ c ∈ i.existingCards, c.cardNumber = i.cardNumber ∧
                           c.expiryDate = i.expiryDate ∧
                           c.cvv = i.cvv

example : Spec.pre { existingCards := [{ cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123 }],
                     cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123 } ∧
          Spec.post { existingCards := [{ cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123 }],
                      cardNumber := "1234567890123456", expiryDate := "12/25", cvv := 123 }
                    { validated := true } := by
  unfold Spec; decide
