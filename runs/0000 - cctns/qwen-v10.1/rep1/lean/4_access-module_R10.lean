import ContractForge
open ContractForge

-- 4/access-module/R10: Any access to cases, and all other activities involving the cases and related documents or data should also need to be stored in the audit trail to ensure legal admissibility and to assist in data recovery.
-- compiles: False · rejects_bad_example: None · checked: False

structure Case where
  id       : Nat
  details  : String
  status   : String
  deriving DecidableEq, Repr

structure Input where
  cases    : List Case
  activity : String
  deriving DecidableEq, Repr

structure Output where
  cases    : List Case
  activity : String
  audit    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.cases = i.cases ∧
                     o.activity = i.activity ∧
                     o.audit = i.activity ++ " at " ++ (i.cases.map (fun c => c.id).toString)

example : Spec.pre { cases := [{ id := 1, details := "Case 1", status := "Open" }],
                     activity := "Viewed Case 1" } ∧
          Spec.post { cases := [{ id := 1, details := "Case 1", status := "Open" }],
                      activity := "Viewed Case 1" }
                    { cases := [{ id := 1, details := "Case 1", status := "Open" }],
                      activity := "Viewed Case 1",
                      audit := "Viewed Case 1 at [1]" } := by
  unfold Spec; decide
