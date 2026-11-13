import ContractForge
open ContractForge

-- 5.1/S3: Level of completeness: A VCD Package will show its full potential when all the requested attestations (all that are necessary to prove all requested criteria) are contained in it.

-- L0 spec

structure Input where
  attestations : List String
  requestedCriteria : List String
  deriving DecidableEq, Repr

structure Output where
  allCriteriaMet : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attestations ≠ [] ∧ i.requestedCriteria ≠ []
  post := fun i o => o.allCriteriaMet = true ↔
    (∀ c ∈ i.requestedCriteria, ∃ a ∈ i.attestations, a = c)

example : Spec.pre { attestations := ["att1", "att2"], requestedCriteria := ["c1", "c2"] } ∧ Spec.post { attestations := ["att1", "att2"], requestedCriteria := ["c1", "c2"] } { allCriteriaMet := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { allCriteriaMet := x.requestedCriteria.forall fun c => x.attestations.any fun a => a = c }
