import ContractForge
open ContractForge

-- 4.3.2.7: Where failure to apply the full service brake is detected the emergency brake shall stop the train in rear of the danger point.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  currentSpeed : Nat
  targetSpeed  : Nat
  brakeApplied : Bool
  dangerPoint  : Nat
  deriving DecidableEq, Repr

structure Output where
  stopped : Bool
  stoppingPoint : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.brakeApplied = false
  post := fun i o => (o.stopped = true ↔
    i.brakeApplied = true ∧ i.currentSpeed ≤ i.dangerPoint) ∧
                     (o.stopped = false →
                      o.stoppingPoint = i.dangerPoint + 1 + (i.currentSpeed - i.targetSpeed) / 2)

example : Spec.pre { currentSpeed := 100, targetSpeed := 0, brakeApplied := false,
                     dangerPoint := 500 } ∧
          Spec.post { currentSpeed := 100, targetSpeed := 0, brakeApplied := false,
                      dangerPoint := 500 }
                    { stopped := true, stoppingPoint := 500 } := by
  unfold Spec; decide
