import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  cvv    : String
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  deriving DecidableEq, Repr

structure Output where
  valid : List CreditCard
  fraud : List CreditCard
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cards.Nodup
  post := fun i o => o.valid.length + o.fraud.length = i.cards.length ∧
                     ∀ c ∈ i.cards, c ∈ o.valid ∨ c ∈ o.fraud ∧
                     (c ∈ o.valid ↔ c.cvv ≠ "123") ∧
                     (c ∈ o.fraud ↔ c.cvv = "123")

example : Spec.pre { cards := [{ number := "1234567890123456", cvv := "123" },
                                { number := "6543210987654321", cvv := "456" }] } ∧
          Spec.post { cards := [{ number := "1234567890123456", cvv := "123" },
                                 { number := "6543210987654321", cvv := "456" }] }
                    { valid := [{ number := "6543210987654321", cvv := "456" }],
                      fraud := [{ number := "1234567890123456", cvv := "123" }] } := by
  unfold Spec; decide
