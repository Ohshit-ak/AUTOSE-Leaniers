import ContractForge
open ContractForge

-- 2.2.9.2/S1: Activity logs, which are tools for investigators to track their actions during a case, should be supported.
-- compiles: True · rejects_bad_example: True · checked: True

structure Activity where
  investigator : String
  action      : String
  timestamp   : String
  deriving DecidableEq, Repr

structure Input where
  activities : List Activity
  deriving DecidableEq, Repr

structure Output where
  activities : List Activity
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.activities.Nodup
  post := fun i o => o.activities = i.activities

example : Spec.pre { activities := [{ investigator := "Alice", action := "opened case", timestamp := "2023-10-01T12:00:00" },
                                      { investigator := "Bob", action := "closed case", timestamp := "2023-10-02T15:00:00" }] } ∧
          Spec.post { activities := [{ investigator := "Alice", action := "opened case", timestamp := "2023-10-01T12:00:00" },
                                      { investigator := "Bob", action := "closed case", timestamp := "2023-10-02T15:00:00" }] }
                    { activities := [{ investigator := "Alice", action := "opened case", timestamp := "2023-10-01T12:00:00" },
                                      { investigator := "Bob", action := "closed case", timestamp := "2023-10-02T15:00:00" }] } := by
  unfold Spec; decide
