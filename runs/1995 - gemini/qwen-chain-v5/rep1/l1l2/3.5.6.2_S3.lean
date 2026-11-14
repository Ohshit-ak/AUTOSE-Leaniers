import ContractForge
open ContractForge

-- 3.5.6.2/S3: Subsystems must be able to detect such danger and report it appropriately.

-- L0 spec

structure Input where
  subsystemStatus : String
  dangerDetected  : Bool
  deriving DecidableEq, Repr

structure Output where
  dangerReported : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subsystemStatus ≠ "" ∧ i.dangerDetected
  post := fun i o => o.dangerReported = true ∧
                     (o.dangerReported = i.dangerDetected)

example : Spec.pre { subsystemStatus := "OK", dangerDetected := true } ∧
          Spec.post { subsystemStatus := "OK", dangerDetected := true }
                    { dangerReported := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { dangerReported := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
