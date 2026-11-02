import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: False · rejects_bad_example: None · checked: False

structure CreditCard where
  number : String
  expiryMonth : Nat
  expiryYear : Nat
  cvv : Nat
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  deriving DecidableEq, Repr

structure Output where
  valid : List CreditCard
  invalid : List CreditCard
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cards.Nodup
  post := fun i o => o.valid.length + o.invalid.length = i.cards.length ∧
                     (∀ c ∈ o.valid, c ∈ i.cards ∧ isFraudValid c = true) ∧
                     (∀ c ∈ o.invalid, c ∈ i.cards ∧ isFraudValid c = false)

-- Helper function to check if a card is valid or not
def isFraudValid (c : CreditCard) : Bool :=
  c.expiryYear ≥ 2023 ∧
  c.expiryMonth < 13 ∧
  c.cvv < 1000

example : Spec.pre { cards := [{ number := "1234567890123456", expiryMonth := 12, expiryYear := 2025, cvv := 123 },
                               { number := "6543210987654321", expiryMonth := 1, expiryYear := 2024, cvv := 456 }] } ∧
          Spec.post { cards := [{ number := "1234567890123456", expiryMonth := 12, expiryYear := 2025, cvv := 123 },
                                 { number := "6543210987654321", expiryMonth := 1, expiryYear := 2024, cvv := 456 }] }
                    { valid := [{ number := "1234567890123456", expiryMonth := 12, expiryYear := 2025, cvv := 123 }],
                      invalid := [{ number := "6543210987654321", expiryMonth := 1, expiryYear := 2024, cvv := 456 }] } := by
  unfold Spec; decide
