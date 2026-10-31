import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: None · checked: False

structure CreditCard where
  number : String
  cvv    : String
  fraud  : Bool
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  number : String
  cvv    : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  fraudDetected : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.number ≠ "" ∧ i.cvv ≠ ""
  post := fun i o => (o.valid = true ↔
    ∃ c ∈ i.cards, c.number = i.number ∧ c.cvv = i.cvv) ∧
                     (o.fraudDetected = true ↔
    ∃ c ∈ i.cards, c.number = i.number ∧ c.cvv = i.cvv ∧ c.fraud = true)

example : Spec.pre { cards := [{ number := "1234567890123456", cvv := "123", fraud := true }],
                     number := "1234567890123456", cvv := "123" } ∧
          Spec.post { cards := [{ number := "1234567890123456", cvv := "123", fraud := true }],
                      number := "1234567890123456", cvv := "123" }
                    { valid := true, fraudDetected := true } := by
  unfold Spec; decide
