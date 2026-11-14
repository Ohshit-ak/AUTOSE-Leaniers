import ContractForge
open ContractForge

-- 4.14.7/I5: The COE Data Engineering Team's Role. Tags and semantics will be analyzed to identify opportunities to consolidate tags towards a single or a minimal number of representations. A "market forces" model can also guide COE Data Engineering in identifying the weak candidates from the strong.8

-- L0 spec

structure Input where
  tags : List String
  deriving DecidableEq, Repr

structure Output where
  consolidatedTags : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.tags.Nodup
  post := fun i o => o.consolidatedTags.Nodup ∧
                     o.consolidatedTags.length ≤ i.tags.length ∧
                     (∀ t ∈ o.consolidatedTags, ∃ t' ∈ i.tags, t' = t) ∧
                     o.consolidatedTags ≠ []

example : Spec.pre { tags := ["tag1", "tag2", "tag3"] } ∧
          Spec.post { tags := ["tag1", "tag2", "tag3"] }
                    { consolidatedTags := ["tag1", "tag2", "tag3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { consolidatedTags := (x.tags.filter (fun t => decide (∃ t' ∈ x.tags, t' = t))).take x.tags.length }
