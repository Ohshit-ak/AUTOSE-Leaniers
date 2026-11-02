import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  expiryMonth : Nat
  expiryYear : Nat
  cvv : String
  deriving DecidableEq, Repr

structure Input where
  card : CreditCard
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.card.expiryMonth < 13 ∧ i.card.expiryYear > 2023
  post := fun i o => (o.valid = true ↔
    i.card.expiryYear > 2023 ∧ i.card.expiryMonth < 12 ∧
    i.card.cvv.length = 3 ∧
    i.card.cvv.toList.all Char.isDigit = true) ∧
    (o.valid = false ↔ o.message = "Invalid credit card")

example : Spec.pre { card := { number := "1234567890123456", expiryMonth := 12, expiryYear := 2024, cvv := "123" } } ∧ Spec.post { card := { number := "1234567890123456", expiryMonth := 12, expiryYear := 2024, cvv := "123" } } { valid := false, message := "Invalid credit card" } := by
  unfold Spec; decide
