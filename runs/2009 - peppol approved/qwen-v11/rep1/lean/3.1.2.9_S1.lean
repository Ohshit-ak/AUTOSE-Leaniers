import ContractForge
open ContractForge

-- 3.1.2.9/S1: Description If an economic operator decides to participate in a particular Call for Tender he can directly retrieve information about relevant evidences and related criteria by using the information published in the Call for Tender.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  evidences : List String
  criteria  : List String
  selected  : List String
  deriving DecidableEq, Repr

structure Output where
  evidences : List String
  criteria  : List String
  selected  : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selected.length > 0
  post := fun i o => 
    (∀ e ∈ o.evidences, e ∈ i.evidences) ∧
    (∀ c ∈ o.criteria, c ∈ i.criteria) ∧
    (∀ s ∈ o.selected, s ∈ i.selected) ∧
    o.evidences.length ≤ i.evidences.length ∧
    o.criteria.length ≤ i.criteria.length ∧
    o.selected.length ≤ i.selected.length ∧
    o.evidences ≠ [] ∧
    o.criteria ≠ [] ∧
    o.selected ≠ []

example : Spec.pre { evidences := ["e1", "e2", "e3"], criteria := ["c1", "c2", "c3"], selected := ["e2", "c2"] } ∧
          Spec.post { evidences := ["e1", "e2", "e3"], criteria := ["c1", "c2", "c3"], selected := ["e2", "c2"] }
                    { evidences := ["e2"], criteria := ["c2"], selected := ["e2", "c2"] } := by
  unfold Spec; decide
