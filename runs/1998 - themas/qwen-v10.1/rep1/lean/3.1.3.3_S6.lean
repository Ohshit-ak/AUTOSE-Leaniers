import ContractForge
open ContractForge

-- 3.1.3.3/S6: A temperature setting value that is received from an individual thermostat shall be compared to the valid temperature range values.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  setting : Nat
  validRange : { min : Nat, max : Nat }
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.validRange.min < i.validRange.max
  post := fun i o => o.valid = true ↔ i.setting ≥ i.validRange.min ∧ i.setting ≤ i.validRange.max

example : Spec.pre { setting := 25, validRange := { min := 10, max := 30 } } ∧
          Spec.post { setting := 25, validRange := { min := 10, max := 30 } }
                    { valid := true } := by
  unfold Spec; decide
