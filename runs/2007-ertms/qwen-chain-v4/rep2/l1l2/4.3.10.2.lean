import ContractForge
open ContractForge

-- 4.3.10.2: All data entered, received or indicated to the driver shall be recorded onboard. All data shall be related to UTC (Universal Time Corrected) and a reference point.

-- L0 spec

structure Input where
  data : List String
  referencePoint : Nat
  deriving DecidableEq, Repr

structure Output where
  recordedData : List String
  referencePoint : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ []
  post := fun i o => o.recordedData = i.data ∧ o.referencePoint = i.referencePoint

example : Spec.pre { data := ["data1", "data2"], referencePoint := 12345 } ∧
          Spec.post { data := ["data1", "data2"], referencePoint := 12345 }
                    { recordedData := ["data1", "data2"], referencePoint := 12345 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { recordedData := x.data, referencePoint := x.referencePoint }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
