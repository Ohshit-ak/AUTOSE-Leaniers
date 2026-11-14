import ContractForge
open ContractForge

-- 2.2.6.3.a/S1: Clinical specimen data should include information about the specimen source/site from which the specimen was taken, symptom date of onset, and whether the sample is acute or convalescent.

-- L0 spec

structure Specimen where
  source  : String
  symptomDate : Nat
  isAcute : Bool
  deriving DecidableEq, Repr

structure Input where
  specimen : Specimen
  deriving DecidableEq, Repr

structure Output where
  source  : String
  symptomDate : Nat
  isAcute : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.source = i.specimen.source ∧
                     o.symptomDate = i.specimen.symptomDate ∧
                     o.isAcute = i.specimen.isAcute

example : Spec.pre { specimen := { source := "nose", symptomDate := 5, isAcute := true } } ∧
          Spec.post { specimen := { source := "nose", symptomDate := 5, isAcute := true } }
                    { source := "nose", symptomDate := 5, isAcute := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { source := x.specimen.source,
    symptomDate := x.specimen.symptomDate,
    isAcute := x.specimen.isAcute }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
