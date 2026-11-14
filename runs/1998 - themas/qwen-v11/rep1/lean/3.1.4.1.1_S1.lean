import ContractForge
open ContractForge

-- 3.1.4.1.1/S1: The THEMAS system shall determine wh en a reported temperature or a changed temperature setting exceeds the limits set by the overtemperature values.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  temperature : Nat
  overtempValues : Nat
  deriving DecidableEq, Repr

structure Output where
  status : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature ≤ 1000 ∧ i.overtempValues ≤ 1000
  post := fun i o => o.status = true ↔ i.temperature > i.overtempValues

example : Spec.pre { temperature := 950, overtempValues := 900 } ∧
          Spec.post { temperature := 950, overtempValues := 900 }
                    { status := true } := by
  unfold Spec; decide
