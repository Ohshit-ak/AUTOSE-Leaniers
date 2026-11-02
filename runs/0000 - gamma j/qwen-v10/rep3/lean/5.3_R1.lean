import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: None · checked: True

structure CreditCard where
  number : String
  cvv    : String
  expiry : String
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  checkFraud : Bool
  deriving DecidableEq, Repr

structure Output where
  valid : List CreditCard
  invalid : List CreditCard
  deriving DecidableEq, Repr

def isFraudulent (card : CreditCard) : Bool :=
  card.cvv.length = 3 ∧
  card.cvv.toList.all Char.isDigit = true ∧
  card.expiry.length = 4 ∧
  card.expiry.toList.all Char.isDigit = true

def Spec : Contract Input Output where
  pre  := fun i => i.cards.Nodup
  post := fun i o =>
    o.valid.length + o.invalid.length = i.cards.length ∧
    ∀ card ∈ i.cards, card ∈ o.valid ∨ card ∈ o.invalid ∧
    (card ∈ o.valid ↔ ¬ isFraudulent card ∧ i.checkFraud) ∧
    (card ∈ o.invalid ↔ isFraudulent card) ∧
    (o.valid.length > 0 ↔ i.checkFraud)

example : Spec.pre { cards := [], checkFraud := false } ∧ Spec.post { cards := [], checkFraud := false } { valid := [], invalid := [] } := by
  unfold Spec; decide
