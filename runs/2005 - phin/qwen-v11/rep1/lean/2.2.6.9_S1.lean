import ContractForge
open ContractForge

-- 2.2.6.9/S1: Systems supporting OM must be able to store laboratory result(s) and link the result(s) to the original laboratory test request.
-- compiles: True · rejects_bad_example: True · checked: True

structure TestRequest where
  specimenId : Nat
  testType   : String
  results    : List String
  deriving DecidableEq, Repr

structure Input where
  specimenId : Nat
  testType   : String
  results    : List String
  deriving DecidableEq, Repr

structure Output where
  specimenId : Nat
  testType   : String
  results    : List String
  linked     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimenId ≠ 0 ∧ i.results.length > 0
  post := fun i o => o.specimenId = i.specimenId ∧
                     o.testType = i.testType ∧
                     o.results = i.results ∧
                     o.linked = true

example : Spec.pre { specimenId := 123, testType := "PCR", results := ["positive"] } ∧
          Spec.post { specimenId := 123, testType := "PCR", results := ["positive"] }
                    { specimenId := 123, testType := "PCR", results := ["positive"], linked := true } := by
  unfold Spec; decide
