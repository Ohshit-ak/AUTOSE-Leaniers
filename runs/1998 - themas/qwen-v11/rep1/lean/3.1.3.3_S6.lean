import ContractForge
open ContractForge

-- 3.1.3.3/S6: A temperature setting value that is received from an individual thermostat shall be compared to the valid temperature range values.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  setting : Nat
  validMin : Nat
  validMax : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.validMin ≤ i.validMax
  post := fun i o => o.valid = (i.validMin ≤ i.setting ∧ i.setting ≤ i.validMax)

example : Spec.pre { setting := 25, validMin := 20, validMax := 30 } ∧
          Spec.post { setting := 25, validMin := 20, validMax := 30 }
                    { valid := true } := by
  unfold Spec; decide
