import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  cvv    : String
  expiry : String
  reason : String
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  number : String
  cvv    : String
  expiry : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  reason : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.number ≠ "" ∧ i.cvv ≠ "" ∧ i.expiry ≠ ""
  post := fun i o => o.valid ↔
    ∃ c ∈ i.cards, c.number = i.number ∧ c.cvv = i.cvv ∧ c.expiry = i.expiry ∧
    (c.reason = "fraud" → o.reason = "fraud") ∧
    (c.reason ≠ "fraud" → o.reason = "valid")

example : Spec.pre { cards := [{ number := "4111111111111111", cvv := "123", expiry := "12/25", reason := "valid" }],
                     number := "4111111111111111", cvv := "123", expiry := "12/25" } ∧
          Spec.post { cards := [{ number := "4111111111111111", cvv := "123", expiry := "12/25", reason := "valid" }],
                      number := "4111111111111111", cvv := "123", expiry := "12/25" }
                    { valid := true, reason := "valid" } := by
  unfold Spec; decide
