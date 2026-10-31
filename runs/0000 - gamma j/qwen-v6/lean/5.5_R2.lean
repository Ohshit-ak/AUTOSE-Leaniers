import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: True · rejects_bad_example: None · checked: False

structure CreditCard where
  cardNumber : String
  expMonth  : Nat
  expYear   : Nat
  deriving DecidableEq, Repr

structure Input where
  existingCards : List CreditCard
  cardNumber    : String
  expMonth     : Nat
  expYear      : Nat
  deriving DecidableEq, Repr

structure Output where
  validated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cardNumber ≠ "" ∧ i.expMonth ≤ 12 ∧ i.expYear ≥ 2023
  post := fun i o => o.validated = true ↔
    ∃ c ∈ i.existingCards, c.cardNumber = i.cardNumber ∧ c.expMonth = i.expMonth ∧ c.expYear = i.expYear

example : Spec.pre { existingCards := [{ cardNumber := "1234567890123456", expMonth := 12, expYear := 2023 }],
                     cardNumber := "1234567890123456", expMonth := 12, expYear := 2023 } ∧
          Spec.post { existingCards := [{ cardNumber := "1234567890123456", expMonth := 12, expYear := 2023 }],
                      cardNumber := "1234567890123456", expMonth := 12, expYear := 2023 }
                    { validated := true } := by
  unfold Spec; decide
