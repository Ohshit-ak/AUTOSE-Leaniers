import ContractForge
open ContractForge

-- 3.1.5.1.3/S5: If the maximum number of heating or cooling units is not running, this process will generate a request to turn on the requested unit.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  maxUnits : Nat
  runningUnits : Nat
  unitId : Nat
  deriving DecidableEq, Repr

structure Output where
  requestGenerated : Bool
  unitId : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.runningUnits < i.maxUnits
  post := fun i o => o.requestGenerated = true ∧
                     o.unitId = i.unitId ∧
                     (o.requestGenerated = true ↔ i.runningUnits + 1 ≤ i.maxUnits)

example : Spec.pre { maxUnits := 5, runningUnits := 4, unitId := 1 } ∧
          Spec.post { maxUnits := 5, runningUnits := 4, unitId := 1 }
                    { requestGenerated := true, unitId := 1 } := by
  unfold Spec; decide
