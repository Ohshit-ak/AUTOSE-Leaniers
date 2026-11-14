import ContractForge
open ContractForge

-- Include descriptive definitions AND synonyms for the Information Resource Definition./S1: Initially, the Registry will not have keyword, thesaurus, or ontology support but it will have a substring search for a number of fields, including definition.
-- compiles: True · rejects_bad_example: True · checked: True

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
    (o.definition = i.definition) ∧
    (o.definition = i.definition →
      (i.definition.toList.all Char.isAlphanum = true) ∧
      (i.definition.length ≤ 100)) ∧
    (o.definition ≠ i.definition →
      o.found = false) ∧
    (o.definition = i.definition →
      o.found = true)

example : Spec.pre { definition := "A descriptive definition." } ∧ Spec.post { definition := "A descriptive definition." } { found := false, definition := "A descriptive definition." } := by
  unfold Spec; decide
