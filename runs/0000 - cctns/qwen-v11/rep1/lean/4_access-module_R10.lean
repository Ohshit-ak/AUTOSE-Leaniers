import ContractForge
open ContractForge

-- 4/access-module/R10: Any access to cases, and all other activities involving the cases and related documents or data should also need to be stored in the audit trail to ensure legal admissibility and to assist in data recovery.
-- compiles: True · rejects_bad_example: False · checked: False

structure Case where
  id       : Nat
  title    : String
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
  pre  := fun i => i.activity ≠ ""
  post := fun i o => o.cases = i.cases ∧
                     o.activity = i.activity ∧
                     (o.audit = i.activity →
                      o.cases.Nodup ∧
                      ∀ c ∈ o.cases, c.status = "active" ∨ c.status = "closed")

example : Spec.pre { cases := [{ id := 1, title := "Case A", status := "active" }],
                     activity := "Review" } ∧
          Spec.post { cases := [{ id := 1, title := "Case A", status := "active" }],
                      activity := "Review" }
                    { cases := [{ id := 1, title := "Case A", status := "active" }],
                      activity := "Review",
                      audit := "Review" } := by
  unfold Spec; decide
