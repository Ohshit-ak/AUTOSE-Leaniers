import ContractForge
open ContractForge

-- 3.1.2.8/S3: If an economic operator decides to participate in a particular Call for Tender he can directly retrieve the relevant criteria and evidences by using the information published in the Call for Tender.

-- L0 spec

structure Input where
  criteria : List String
  evidences : List String
  deriving DecidableEq, Repr

structure Output where
  relevantCriteria : List String
  relevantEvidences : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ [] ∧ i.evidences ≠ []
  post := fun i o => o.relevantCriteria = i.criteria ∧
                     o.relevantEvidences = i.evidences

example : Spec.pre { criteria := ["Criterion A", "Criterion B"], evidences := ["Evidence 1", "Evidence 2"] } ∧
          Spec.post { criteria := ["Criterion A", "Criterion B"], evidences := ["Evidence 1", "Evidence 2"] }
                    { relevantCriteria := ["Criterion A", "Criterion B"], relevantEvidences := ["Evidence 1", "Evidence 2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { relevantCriteria := x.criteria,
    relevantEvidences := x.evidences }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
