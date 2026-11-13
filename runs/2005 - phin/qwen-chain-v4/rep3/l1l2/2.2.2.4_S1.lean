import ContractForge
open ContractForge

-- 2.2.2.4/S1: Systems supporting OM should have the ability to capture changes to the case definition that occur as the health event evolves.

-- L0 spec

structure CaseDefinition where
  criteria : String
  deriving DecidableEq, Repr

structure HealthEvent where
  caseDefinitions : List CaseDefinition
  deriving DecidableEq, Repr

structure Input where
  caseDefinitions : List CaseDefinition
  deriving DecidableEq, Repr

structure Output where
  caseDefinitions : List CaseDefinition
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.caseDefinitions.Nodup
  post := fun i o => o.caseDefinitions = i.caseDefinitions ∧
                     o.caseDefinitions.Nodup

example : Spec.pre { caseDefinitions := [{ criteria := "Symptom A" },
                                          { criteria := "Symptom B" }] } ∧
          Spec.post { caseDefinitions := [{ criteria := "Symptom A" },
                                          { criteria := "Symptom B" }] }
                    { caseDefinitions := [{ criteria := "Symptom A" },
                                          { criteria := "Symptom B" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { caseDefinitions := x.caseDefinitions }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
