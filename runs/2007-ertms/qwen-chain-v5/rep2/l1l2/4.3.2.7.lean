import ContractForge
open ContractForge

-- 4.3.2.7: Where failure to apply the full service brake is detected the emergency brake shall stop the train in rear of the danger point.

-- L0 spec

structure Input where
  currentSpeed : Nat
  targetSpeed  : Nat
  brakeApplied : Bool
  dangerPoint  : Nat
  emergencyBrakeApplied : Bool
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
                      o.stoppingPoint = i.dangerPoint + 1 - (i.currentSpeed - i.targetSpeed)) ∧
                     (i.emergencyBrakeApplied = true →
                      o.stopped = false)

example : Spec.pre { currentSpeed := 50, targetSpeed := 60, brakeApplied := false, dangerPoint := 100, emergencyBrakeApplied := true } ∧ Spec.post { currentSpeed := 50, targetSpeed := 60, brakeApplied := false, dangerPoint := 100, emergencyBrakeApplied := true } { stopped := false, stoppingPoint := 101 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { stopped := decide (x.brakeApplied = true ∧ x.currentSpeed ≤ x.dangerPoint),
    stoppingPoint := if x.brakeApplied = true ∧ x.currentSpeed ≤ x.dangerPoint then x.dangerPoint + 1 - (x.currentSpeed - x.targetSpeed) else 0 }
