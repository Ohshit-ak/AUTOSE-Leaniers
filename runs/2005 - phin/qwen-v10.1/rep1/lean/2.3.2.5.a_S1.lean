import ContractForge
open ContractForge

-- 2.3.2.5.a/S1: If the specimen/sample was created from another specimen/sample (e.g., aliquots, and new specimen types created from a source sample), laboratory results for the child specimens/samples must be linked to the corresponding parent specimen/sample.
-- compiles: True · rejects_bad_example: True · checked: True

structure Specimen where
  id          : Nat
  parent      : Option Nat
  sampleType  : String
  laboratoryResults : String
  deriving DecidableEq, Repr

structure Input where
  specimens : List Specimen
  deriving DecidableEq, Repr

structure Output where
  specimens : List Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimens.Nodup
  post := fun i o =>
    o.specimens.Nodup ∧
    ∀ s ∈ o.specimens, ∃ p ∈ i.specimens, s.parent = p.id ∧
    (s.sampleType != "original" ↔ p.sampleType = "original") ∧
    s.laboratoryResults = p.laboratoryResults

example : Spec.pre { specimens := [{ id := 1, parent := some 2, sampleType := "aliquot", laboratoryResults := "Result1" }, { id := 2, parent := none, sampleType := "original", laboratoryResults := "Result2" }] } ∧ Spec.post { specimens := [{ id := 1, parent := some 2, sampleType := "aliquot", laboratoryResults := "Result1" }, { id := 2, parent := none, sampleType := "original", laboratoryResults := "Result2" }] } { specimens := [] } := by
  unfold Spec; decide
