import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  expMonth : Nat
  expYear : Nat
  cvv : Nat
  deriving DecidableEq, Repr

structure Input where
  card : CreditCard
  isFraudulent : Bool
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  reason : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.card.expMonth ≤ 12 ∧ i.card.expYear ≥ 2023
  post := fun i o => (o.valid = true ↔
    i.card.expMonth = 12 ∧ i.card.expYear = 2023 ∧
    (i.card.expMonth < 12 ∨ i.card.expYear > 2023) →
    o.reason = "Card expired" ∨ o.reason = "Future date") ∧
    (o.valid = false ↔
    (i.card.expMonth = 12 ∧ i.card.expYear = 2023) ∧
    i.isFraudulent = true)

example : Spec.pre { card := { number := "1234567890123456", expMonth := 12, expYear := 2023, cvv := 123 }, isFraudulent := false } ∧ Spec.post { card := { number := "1234567890123456", expMonth := 12, expYear := 2023, cvv := 123 }, isFraudulent := false } { valid := true, reason := "Card expired" } := by
  unfold Spec; decide
