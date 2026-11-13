import ContractForge
open ContractForge

-- 3.1.4.1.3/S1: The THEMAS system shall compare the reported temperature value to the temperature setting and detect when the temperature value exceeds the specified limits.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  reportedTemp : Nat
  setting      : Nat
  upperLimit   : Nat
  lowerLimit   : Nat
  deriving DecidableEq, Repr

structure Output where
  status : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.upperLimit > i.lowerLimit
  post := fun i o => o.status = "within limits" ↔ i.reportedTemp ≤ i.upperLimit ∧ i.lowerLimit ≤ i.reportedTemp

example : Spec.pre { reportedTemp := 25, setting := 20, upperLimit := 30, lowerLimit := 15 } ∧
          Spec.post { reportedTemp := 25, setting := 20, upperLimit := 30, lowerLimit := 15 }
                    { status := "within limits" } := by
  unfold Spec; decide
