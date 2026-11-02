import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  cvv    : String
  fraudulent : Bool
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  number : String
  cvv    : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  fraudulent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.number ≠ "" ∧ i.cvv ≠ ""
  post := fun i o => (o.valid = true ↔
    ∃ c ∈ i.cards, c.number = i.number ∧ c.cvv = i.cvv) ∧
                     (o.fraudulent = true ↔
    ∃ c ∈ i.cards, c.number = i.number ∧ c.cvv = i.cvv ∧ c.fraudulent = true)

example : Spec.pre { cards := [{ number := "1234567890123456", cvv := "123", fraudulent := false },
                               { number := "6543210987654321", cvv := "456", fraudulent := true }],
                     number := "1234567890123456", cvv := "123" } ∧
          Spec.post { cards := [{ number := "1234567890123456", cvv := "123", fraudulent := false },
                                { number := "6543210987654321", cvv := "456", fraudulent := true }],
                      number := "1234567890123456", cvv := "123" }
                    { valid := true, fraudulent := false } := by
  unfold Spec; decide
