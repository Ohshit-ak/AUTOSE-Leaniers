import ContractForge
open ContractForge

-- 3.2.4.10/S4: As it is quite complex to establish a common and unique classification scheme cross-border and cross-sector, business document instances should be carry metadata about classification schemes they use."

-- L0 spec

structure ClassificationScheme where
  id : String
  description : String
  deriving DecidableEq, Repr

structure Input where
  documentMetadata : List String
  classificationSchemes : List ClassificationScheme
  deriving DecidableEq, Repr

structure Output where
  documentMetadata : List String
  classificationSchemes : List ClassificationScheme
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.documentMetadata ≠ []
  post := fun i o =>
    o.documentMetadata = i.documentMetadata ∧
    o.classificationSchemes = i.classificationSchemes ∧
    (∀ s ∈ o.classificationSchemes, s.id ∈ i.documentMetadata)

example : Spec.pre { documentMetadata := ["scheme1", "scheme2"], classificationSchemes := [{ id := "scheme1", description := "Description 1" }, { id := "scheme2", description := "Description 2" }] } ∧
          Spec.post { documentMetadata := ["scheme1", "scheme2"], classificationSchemes := [{ id := "scheme1", description := "Description 1" }, { id := "scheme2", description := "Description 2" }] }
                    { documentMetadata := ["scheme1", "scheme2"], classificationSchemes := [{ id := "scheme1", description := "Description 1" }, { id := "scheme2", description := "Description 2" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { documentMetadata := x.documentMetadata, classificationSchemes := x.classificationSchemes }
