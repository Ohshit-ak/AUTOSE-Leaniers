import ContractForge
open ContractForge

-- 2.2.6.9/S1: Systems supporting OM must be able to store laboratory result(s) and link the result(s) to the original laboratory test request.
-- compiles: True · rejects_bad_example: True · checked: True

structure TestRequest where
  specimenId : Nat
  testType   : String
  deriving DecidableEq, Repr

structure LaboratoryResult where
  specimenId : Nat
  testType   : String
  result     : String
  deriving DecidableEq, Repr

structure Input where
  testRequests : List TestRequest
  results      : List LaboratoryResult
  deriving DecidableEq, Repr

structure Output where
  testRequests : List TestRequest
  results      : List LaboratoryResult
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.testRequests.Nodup && i.results.Nodup
  post := fun i o => o.testRequests = i.testRequests ∧
                     o.results = i.results ∧
                     ∀ r ∈ o.results, ∃ t ∈ o.testRequests, t.specimenId = r.specimenId ∧ t.testType = r.testType

example : Spec.pre { testRequests := [{ specimenId := 1, testType := "Virus" }],
                     results := [{ specimenId := 1, testType := "Virus", result := "Positive" }] } ∧
          Spec.post { testRequests := [{ specimenId := 1, testType := "Virus" }],
                      results := [{ specimenId := 1, testType := "Virus", result := "Positive" }] }
                    { testRequests := [{ specimenId := 1, testType := "Virus" }],
                      results := [{ specimenId := 1, testType := "Virus", result := "Positive" }] } := by
  unfold Spec; decide
