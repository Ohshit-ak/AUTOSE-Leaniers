import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: True · rejects_bad_example: None · checked: False

structure CreditCard where
  number : String
  expiration : String
  cvv : Nat
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  number : String
  expiration : String
  cvv : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.number ≠ "" ∧ i.expiration ≠ "" ∧ 0 < i.cvv
  post := fun i o => o.valid = true ↔
    ∃ c ∈ i.cards, c.number = i.number ∧ c.expiration = i.expiration ∧ c.cvv = i.cvv

example : Spec.pre { cards := [{ number := "1234567890123456", expiration := "12/23", cvv := 123 },
                                { number := "6543210987654321", expiration := "03/24", cvv := 456 }],
                     number := "1234567890123456", expiration := "12/23", cvv := 123 } ∧
          Spec.post { cards := [{ number := "1234567890123456", expiration := "12/23", cvv := 123 },
                                { number := "6543210987654321", expiration := "03/24", cvv := 456 }],
                      number := "1234567890123456", expiration := "12/23", cvv := 123 }
                    { valid := true } := by
  unfold Spec; decide
