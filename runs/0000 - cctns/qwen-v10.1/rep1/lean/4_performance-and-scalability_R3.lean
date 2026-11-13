import ContractForge
open ContractForge

-- 4/performance-and-scalability/R3: The System must be able to retrieve and display within 5-8 seconds the case which has been accessed within the previous 2 months, regardless of storage capacity or number of cases in the system. This requirement is intended to allow for rapid retrieval of frequently-used cases, on the understanding that frequency of use is typically correlated with recent use.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  caseId : String
  deriving DecidableEq, Repr

structure Output where
  caseId   : String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.caseId = i.caseId ∧ o.elapsedMicros ≤ 8000000

example : Spec.pre { caseId := "C123" } ∧
          Spec.post { caseId := "C123", elapsedMicros := 7500000 } := by
  unfold Spec; decide
