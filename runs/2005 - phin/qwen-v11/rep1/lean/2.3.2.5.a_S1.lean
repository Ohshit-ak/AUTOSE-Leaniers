import ContractForge
open ContractForge

-- 2.3.2.5.a/S1: If the specimen/sample was created from another specimen/sample (e.g., aliquots, and new specimen types created from a source sample), laboratory results for the child specimens/samples must be linked to the corresponding parent specimen/sample.
-- compiles: True · rejects_bad_example: True · checked: True

structure Specimen where
  id          : Nat
  parent      : Option Nat
  testResults : List String
  deriving DecidableEq, Repr

structure Input where
  specimens : List Specimen
  deriving DecidableEq, Repr

structure Output where
  specimens : List Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimens.all (fun s => s.parent.isNone ∨ s.parent.isSome)
  post := fun i o =>
    ∀ s ∈ o.specimens, 
      s.parent.isSome → 
      ∃ p ∈ i.specimens, 
        p.id = s.parent.getD 0 ∧
        s.testResults = p.testResults

example : Spec.pre { specimens := [{ id := 1, parent := none, testResults := ["A1", "A2"] }, { id := 2, parent := some 1, testResults := ["B1", "B2"] }] } ∧ Spec.post { specimens := [{ id := 1, parent := none, testResults := ["A1", "A2"] }, { id := 2, parent := some 1, testResults := ["B1", "B2"] }] } { specimens := [] } := by
  unfold Spec; decide
