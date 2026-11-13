import ContractForge
open ContractForge

-- 3.1.4.1.1/S1: The THEMAS system shall determine wh en a reported temperature or a changed temperature setting exceeds the limits set by the overtemperature values.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  temperature : Nat
  overtemp    : Nat
  setting     : Nat
  deriving DecidableEq, Repr

structure Output where
  status : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature ≠ 0 ∧ i.overtemp ≠ 0 ∧ i.setting ≠ 0
  post := fun i o => o.status = true ↔ (i.temperature > i.overtemp ∨ i.temperature > i.setting)

example : Spec.pre { temperature := 100, overtemp := 90, setting := 80 } ∧
          Spec.post { temperature := 100, overtemp := 90, setting := 80 }
                    { status := true } := by
  unfold Spec; decide
