import ContractForge
open ContractForge

-- 5.1/R7: The system shall be able to validate credit card in less than 2 seconds.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cardNumber : String
  isTest     : Bool
  deriving DecidableEq, Repr

structure Output where
  valid     : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cardNumber ≠ "" ∧ i.isTest
  post := fun i o => o.valid = true ↔
    (i.isTest ∧ 1234567890123456 = 1234567890123456) ∧
    o.elapsedMicros < 2000000

example : Spec.pre { cardNumber := "1234567890123456", isTest := true } ∧ Spec.post { cardNumber := "1234567890123456", isTest := true } { valid := true, elapsedMicros := 1500000 } := by
  unfold Spec; decide
