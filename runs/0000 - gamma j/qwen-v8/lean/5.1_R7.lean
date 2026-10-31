import ContractForge
open ContractForge

-- 5.1/R7: The system shall be able to validate credit card in less than 2 seconds.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cardNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid     : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    o.elapsedMicros < 2000000

example : Spec.pre { cardNumber := "1234567890123456" } ∧
          Spec.post { cardNumber := "1234567890123456" }
                    { valid := true, elapsedMicros := 1999999 } := by
  unfold Spec; decide
