import ContractForge
open ContractForge

-- 3.2.4.9/S9: Requirement If attestations are described sufficiently in multiple lingual versions they SHOULD be included first to stages 3 and 4.

-- L0 spec

structure Input where
  attestations : List String
  language     : String
  deriving DecidableEq, Repr

structure Output where
  included : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attestations.length > 0
  post := fun i o => o.included = true ↔
    (i.language = "en" ∧ i.attestations.length > 1) ∨
    (i.language ≠ "en" ∧ i.attestations.length > 0)

example : Spec.pre { attestations := ["att1", "att2"], language := "en" } ∧
          Spec.post { attestations := ["att1", "att2"], language := "en" }
                    { included := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { included := decide (x.language = "en" ∧ x.attestations.length > 1 ∨ x.language ≠ "en" ∧ x.attestations.length > 0) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
