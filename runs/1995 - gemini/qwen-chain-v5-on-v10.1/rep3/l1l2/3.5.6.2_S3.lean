import ContractForge
open ContractForge

-- 3.5.6.2/S3: Subsystems must be able to detect such danger and report it appropriately.

-- L0 spec

structure Input where
  dangerDetected : Bool
  reportSent     : Bool
  deriving DecidableEq, Repr

structure Output where
  dangerDetected : Bool
  reportSent     : Bool
  reportReceived : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dangerDetected = true
  post := fun i o => (o.dangerDetected = true ∧ o.reportSent = true ∧ o.reportReceived = true) ↔
                     (i.dangerDetected = true)

example : Spec.pre { dangerDetected := true, reportSent := false } ∧
          Spec.post { dangerDetected := true, reportSent := false }
                    { dangerDetected := true, reportSent := true, reportReceived := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { dangerDetected := x.dangerDetected, reportSent := true, reportReceived := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
