import ContractForge
open ContractForge

-- 4.3.1/S8: This way, the Austrian VCD implementation will ensure full pan-European interoperability and will lead to a dynamic situation regarding the legal rule set and its flexibility to adapt to legal and organisational changes.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  legalRules : List String
  deriving DecidableEq, Repr

structure Output where
  legalRules : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.legalRules.Nodup
  post := fun i o => o.legalRules = i.legalRules ∧
                     (∃ r ∈ o.legalRules, r.length > 10) ∧
                     (∀ r ∈ o.legalRules, r.length ≤ 100) ∧
                     (o.legalRules.length > i.legalRules.length →
                      ∃ r ∈ i.legalRules, r.length > 50) ∧
                     (o.legalRules.length ≤ i.legalRules.length →
                      ∀ r ∈ i.legalRules, r.length ≤ 50)

example : Spec.pre { legalRules := ["rule1", "rule2", "rule3"] } ∧
          Spec.post { legalRules := ["rule1", "rule2", "rule3", "newRule"] }
                    { legalRules := ["rule1", "rule2", "rule3", "newRule"] } := by
  unfold Spec; decide
