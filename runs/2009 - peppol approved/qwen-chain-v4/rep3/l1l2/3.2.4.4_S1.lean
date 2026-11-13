import ContractForge
open ContractForge

-- 3.2.4.4/S1: Description A VCD package will show its full potential only when all requested evidences (all that are necessary to prove all the requested criteria) are contained within it.

-- L0 spec

structure Evidence where
  name   : String
  content : String
  deriving DecidableEq, Repr

structure Input where
  criteria : List String
  evidences : List Evidence
  deriving DecidableEq, Repr

structure Output where
  complete : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o => o.complete = true ↔
    (∀ c ∈ i.criteria, ∃ e ∈ i.evidences, e.content.contains c)

example : Spec.pre { criteria := ["criterion1", "criterion2"], evidences := [] } ∧ Spec.post { criteria := ["criterion1", "criterion2"], evidences := [] } { complete := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { complete := x.criteria ≠ [] ∧
    (∀ c, c ∈ x.criteria → ∃ e, e ∈ x.evidences ∧ e.content.contains c) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
