import ContractForge
open ContractForge

-- 3.1.2.9/S1: Description If an economic operator decides to participate in a particular Call for Tender he can directly retrieve information about relevant evidences and related criteria by using the information published in the Call for Tender.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { evidences := (x.evidences.filter (fun e => decide (e ∈ x.evidences))).take x.evidences.length,
    criteria := (x.criteria.filter (fun c => decide (c ∈ x.criteria))).take x.criteria.length,
    selected := (x.selected.filter (fun s => decide (s ∈ x.selected))).take x.selected.length }
