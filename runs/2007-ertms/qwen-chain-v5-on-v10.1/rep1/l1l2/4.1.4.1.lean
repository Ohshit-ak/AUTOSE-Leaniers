import ContractForge
open ContractForge

-- 4.1.4.1: Partial Supervision shall be selected either by the Driver, or by information received from track-to-train transmission.

-- L0 spec

structure Input where
  driverSelection : Bool
  trackToTrain    : Bool
  deriving DecidableEq, Repr

structure Output where
  partialSupervision : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverSelection ∨ i.trackToTrain
  post := fun i o => o.partialSupervision = true ↔ (i.driverSelection ∨ i.trackToTrain)

example : Spec.pre { driverSelection := true, trackToTrain := false } ∧
          Spec.post { driverSelection := true, trackToTrain := false }
                    { partialSupervision := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { partialSupervision := decide ((x.driverSelection ∨ x.trackToTrain)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
