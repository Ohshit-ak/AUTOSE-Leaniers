import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: None · checked: False

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
                     ∀ c ∈ o.valid, c ∈ i.cards ∧ c.cvv ≠ "123" ∧ c.number ≠ "4111111111111111" ∧
                     ∀ c ∈ o.fraud, c ∈ i.cards ∧ (c.cvv = "123" ∨ c.number = "4111111111111111")

example : Spec.pre { cards := [{ number := "4111111111111112", cvv := "456" }] } ∧ Spec.post { cards := [{ number := "4111111111111112", cvv := "456" }] } { valid := [{ number := "4111111111111112", cvv := "456" }], fraud := [] } := by
  unfold Spec; decide
