import ContractForge
open ContractForge

-- 2.2.6.2/S1: The subject of a specimen/sample collected for laboratory testing must be linked to the specimen/sample by an identifier (i.e., Subject ID) that is unique within the jurisdiction.

-- L0 spec

structure Specimen where
  subjectId : String
  deriving DecidableEq, Repr

structure Input where
  specimens : List Specimen
  subjectId : String
  deriving DecidableEq, Repr

structure Output where
  specimens : List Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subjectId ≠ ""
  post := fun i o => o.specimens.length = i.specimens.length ∧
                     (∀ s ∈ o.specimens, s.subjectId = i.subjectId) ∧
                     o.specimens.Nodup

example : Spec.pre { specimens := [{ subjectId := "12345" }],
                     subjectId := "12345" } ∧
          Spec.post { specimens := [{ subjectId := "12345" }],
                      subjectId := "12345" }
                    { specimens := [{ subjectId := "12345" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { specimens := x.specimens }
