import ContractForge
open ContractForge

-- 3.1.5.1.3/S5: If the maximum number of heating or cooling units is not running, this process will generate a request to turn on the requested unit.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { requestGenerated := true,
    unitId := x.unitId }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
