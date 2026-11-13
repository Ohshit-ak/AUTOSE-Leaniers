import ContractForge
open ContractForge

-- 4.3.3.2d: If the release speed is calculated on board it shall ensure that the train will stop before reaching the danger point
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  distanceToDangerPoint : Nat
  maxDecelerationRate   : Nat
  initialSpeed          : Nat
  deriving DecidableEq, Repr

structure Output where
  releaseSpeed : Nat
  shallStopBeforeDanger : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.distanceToDangerPoint ∧ 0 < i.maxDecelerationRate ∧ 0 < i.initialSpeed
  post := fun i o => o.shallStopBeforeDanger ↔
    (o.releaseSpeed = 0 ∧ i.initialSpeed ≤ i.maxDecelerationRate * i.distanceToDangerPoint) ∨
    (o.releaseSpeed > 0 ∧
     (o.releaseSpeed ≤ i.initialSpeed ∧
      o.releaseSpeed ≤ i.maxDecelerationRate * (i.distanceToDangerPoint - 1) + o.releaseSpeed))

example : Spec.pre { distanceToDangerPoint := 100, maxDecelerationRate := 5, initialSpeed := 100 } ∧
          Spec.post { distanceToDangerPoint := 100, maxDecelerationRate := 5, initialSpeed := 100 }
                    { releaseSpeed := 50, shallStopBeforeDanger := true } := by
  unfold Spec; decide
