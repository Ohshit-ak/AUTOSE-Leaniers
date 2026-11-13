import ContractForge
open ContractForge

-- Include descriptive definitions AND synonyms for the Information Resource Definition./S1: Initially, the Registry will not have keyword, thesaurus, or ontology support but it will have a substring search for a number of fields, including definition.

-- L0 spec

structure Input where
  definition : String
  deriving DecidableEq, Repr

structure Output where
  found     : Bool
  definition: String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.definition ≠ ""
  post := fun i o => o.found ↔
    (i.definition.length ≤ 100 ∧
     i.definition.toList.all Char.isAlphanum = true) ∧
    o.definition = i.definition

example : Spec.pre { definition := "A descriptive definition." } ∧ Spec.post { definition := "A descriptive definition." } { found := false, definition := "A descriptive definition." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { found := x.definition.length ≤ 100 ∧ x.definition.toList.all Char.isAlphanum,
    definition := x.definition }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
