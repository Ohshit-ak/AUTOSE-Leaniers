import ContractForge
open ContractForge

-- 3.2.3.1/S1: A selection of such documents will be included in any VCD; they will be produced by national units according to national legislation.

-- L0 spec

structure Input where
  documents : List String
  nationalLegislation : String
  deriving DecidableEq, Repr

structure Output where
  vcdDocuments : List String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the national legislation and is a non-empty string of alphabetic characters
def Wanted (i : Input) (d : String) : Bool :=
  d ≠ "" ∧ d.all Char.isAlpha

def Spec : Contract Input Output where
  pre  := fun i => i.documents.Nodup ∧ i.nationalLegislation ≠ ""
  post := fun i o =>
    (∀ d ∈ o.vcdDocuments, d ∈ i.documents ∧ Wanted i d) ∧
    (o.vcdDocuments.length ≤ i.documents.length) ∧
    (o.vcdDocuments.length = i.documents.length →
      ∀ d ∈ i.documents, d ∈ o.vcdDocuments ∧ Wanted i d) ∧
    (o.vcdDocuments.length < i.documents.length →
      ∃ d ∈ i.documents, d ∉ o.vcdDocuments ∧ Wanted i d)

example : Spec.pre { documents := [], nationalLegislation := "leg1" } ∧ Spec.post { documents := [], nationalLegislation := "leg1" } { vcdDocuments := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { vcdDocuments := 
      (x.documents.filter (fun d => d ∈ x.documents ∧ Wanted x d)).take x.documents.length }
