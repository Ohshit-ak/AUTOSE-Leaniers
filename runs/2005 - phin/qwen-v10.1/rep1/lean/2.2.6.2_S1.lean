import ContractForge
open ContractForge

-- 2.2.6.2/S1: The subject of a specimen/sample collected for laboratory testing must be linked to the specimen/sample by an identifier (i.e., Subject ID) that is unique within the jurisdiction.
-- compiles: True · rejects_bad_example: True · checked: True

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
