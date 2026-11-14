import ContractForge
open ContractForge

-- 2.2.6.1/S1: Specimens/samples collected for laboratory testing must be assigned an identifier (i.e., Specimen ID) that is unique within the jurisdiction.

-- L0 spec

structure Specimen where
  id         : String
  jurisdiction : String
  deriving DecidableEq, Repr

structure Input where
  specimens : List Specimen
  jurisdiction : String
  deriving DecidableEq, Repr

structure Output where
  specimens : List Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.jurisdiction ≠ ""
  post := fun i o => o.specimens.Nodup ∧
                     (∀ s ∈ o.specimens, s.jurisdiction = i.jurisdiction ∧
                      ∃ s' ∈ i.specimens, s'.id = s.id) ∧
                     o.specimens ≠ []

example : Spec.pre { specimens := [{ id := "1234", jurisdiction := "CA" }],
                     jurisdiction := "CA" } ∧
          Spec.post { specimens := [{ id := "1234", jurisdiction := "CA" }],
                      jurisdiction := "CA" }
                    { specimens := [{ id := "1234", jurisdiction := "CA" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { specimens := x.specimens.filter (fun s => decide (s.jurisdiction = x.jurisdiction ∧
                      ∃ s' ∈ x.specimens, s'.id = s.id))
    | specimens => specimens.Nodup
    | specimens => specimens ≠ [] }
