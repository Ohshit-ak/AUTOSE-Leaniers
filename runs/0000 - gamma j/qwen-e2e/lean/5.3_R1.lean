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
  fraudulent : List CreditCard
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cards.Nodup
  post := fun i o => o.valid.length + o.fraudulent.length = i.cards.length ∧
                     ∀ c ∈ i.cards, c ∈ o.valid ∨ c ∈ o.fraudulent ∧
                     (c ∈ o.valid ↔
                       (10 ≤ c.expiryYear ∧ c.expiryYear ≤ 30) ∧
                       (1 ≤ c.expiryMonth ∧ c.expiryMonth ≤ 12) ∧
                       (c.cvv ≥ 100) ∧
                       (c.number.toList.all Char.isDigit = true) ∧
                       (c.number.length = 16)) ∧
                     (c ∈ o.fraudulent ↔
                       (c.expiryYear < 10) ∨
                       (c.expiryMonth > 12) ∨
                       (c.cvv < 100) ∨
                       (c.number.toList.all Char.isDigit ≠ true) ∨
                       (c.number.length ≠ 16))

example : Spec.pre { cards := [{ number := "1234567890123456", expiryMonth := 12, expiryYear := 25, cvv := 123 },
                               { number := "6543210987654321", expiryMonth := 1, expiryYear := 20, cvv := 111 }] } ∧
          Spec.post { cards := [{ number := "1234567890123456", expiryMonth := 12, expiryYear := 25, cvv := 123 },
                                { number := "6543210987654321", expiryMonth := 1, expiryYear := 20, cvv := 111 }] }
                    { valid := [{ number := "1234567890123456", expiryMonth := 12, expiryYear := 25, cvv := 123 }],
                      fraudulent := [{ number := "6543210987654321", expiryMonth := 1, expiryYear := 20, cvv := 111 }] } := by
  unfold Spec; decide
