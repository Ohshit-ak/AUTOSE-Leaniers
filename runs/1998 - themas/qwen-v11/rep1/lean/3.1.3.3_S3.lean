import ContractForge
open ContractForge

-- 3.1.3.3/S3: A current temperature value that is received from an individual thermostat shall be compared to the valid temperature range values.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  temperature : Nat
  valid_min   : Nat
  valid_max   : Nat
  deriving DecidableEq, Repr

structure Output where
  within_range : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.valid_min < i.valid_max
  post := fun i o => o.within_range = true ↔ i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max

example : Spec.pre { temperature := 22, valid_min := 18, valid_max := 25 } ∧
          Spec.post { temperature := 22, valid_min := 18, valid_max := 25 }
                    { within_range := true } := by
  unfold Spec; decide
