import ContractForge
open ContractForge

-- 0/I2: The goals of chapter 3 will be described in more detail. The term "framework" thereby seems to be misleading and will be replaced by a more suitable expression. The general descriptions and structure of chapter 3 will be maintained. Responding to criticism from the review, strong interconnections will be added to the subsequent deliverable D2.2, which will give a more detailed description of the organisational, semantic, technical and legal specifications of the VCD concept. In D2.2., the requirements stated in D 2.1 will be reconsidered and transformed into a tabular collection of functional and non-functional requirements grouped for different components of the overall VCD concept (see subsequent contents of D 2.2)

-- L0 spec

structure Input where
  framework : String
  description : String
  requirements : List String
  deriving DecidableEq, Repr

structure Output where
  framework : String
  description : String
  requirements : List String
  functionalRequirements : List String
  nonFunctionalRequirements : List String
  components : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.framework ≠ "" ∧ i.description ≠ ""
  post := fun i o => 
    o.framework = i.framework ∧
    o.description = i.description ∧
    o.requirements = i.requirements ∧
    o.functionalRequirements = [] ∧
    o.nonFunctionalRequirements = [] ∧
    o.components = []

example : Spec.pre { framework := "VCD", description := "Organisational, semantic, technical, and legal specifications", requirements := ["req1", "req2"] } ∧
          Spec.post { framework := "VCD", description := "Organisational, semantic, technical, and legal specifications", requirements := ["req1", "req2"] }
                    { framework := "VCD", description := "Organisational, semantic, technical, and legal specifications", requirements := ["req1", "req2"], functionalRequirements := [], nonFunctionalRequirements := [], components := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { framework := x.framework,
    description := x.description,
    requirements := x.requirements,
    functionalRequirements := [],
    nonFunctionalRequirements := [],
    components := [] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
