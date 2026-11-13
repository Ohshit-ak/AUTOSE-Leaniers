import ContractForge
open ContractForge

-- 2.2.6.1/S1: Specimens/samples collected for laboratory testing must be assigned an identifier (i.e., Specimen ID) that is unique within the jurisdiction.
-- compiles: False · rejects_bad_example: None · checked: False

structure Specimen where
  id : String
  -- other fields like collectionDate, testType, etc. can be added as needed
  deriving DecidableEq, Repr

structure Input where
  specimens : List Specimen
  jurisdictionSize : Nat
  deriving DecidableEq, Repr

structure Output where
  specimens : List Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimens.all (fun s => s.id ≠ "")
  post := fun i o => o.specimens.Nodup ∧
                     (o.specimens.all (fun s => s.id.Nodup ∧
                                               o.specimens.count (fun s' => s'.id = s.id) = 1)) ∧
                     o.specimens.length = i.specimens.length

example : Spec.pre { specimens := [{ id := "S123" }, { id := "S456" }], jurisdictionSize := 100 } ∧
          Spec.post { specimens := [{ id := "S123" }, { id := "S456" }] }
                    { specimens := [{ id := "S123" }, { id := "S456" }] } := by
  unfold Spec; decide
