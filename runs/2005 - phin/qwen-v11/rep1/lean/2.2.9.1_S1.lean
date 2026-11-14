import ContractForge
open ContractForge

-- 2.2.9.1/S1: Systems supporting OM should capture information such as the date and time of an activity, activity type, who initiated the activity, and contact information to generate activity logs for management purposes.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  date       : String
  time       : String
  activity   : String
  initiator  : String
  contact    : String
  deriving DecidableEq, Repr

structure Output where
  logged     : Bool
  date       : String
  time       : String
  activity   : String
  initiator  : String
  contact    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.date ≠ "" ∧ i.time ≠ "" ∧ i.activity ≠ "" ∧ i.initiator ≠ "" ∧ i.contact ≠ ""
  post := fun i o => o.logged = true ∧
                     (if i.date = "" then o.date = "N/A" else o.date = i.date) ∧
                     (if i.time = "" then o.time = "N/A" else o.time = i.time) ∧
                     (if i.activity = "" then o.activity = "N/A" else o.activity = i.activity) ∧
                     (if i.initiator = "" then o.initiator = "N/A" else o.initiator = i.initiator) ∧
                     (if i.contact = "" then o.contact = "N/A" else o.contact = i.contact)

example : Spec.pre { date := "2023-10-05", time := "14:30", activity := "System Update", initiator := "Admin", contact := "admin@example.com" } ∧
          Spec.post { date := "2023-10-05", time := "14:30", activity := "System Update", initiator := "Admin", contact := "admin@example.com" }
                    { logged := true, date := "2023-10-05", time := "14:30", activity := "System Update", initiator := "Admin", contact := "admin@example.com" } := by
  unfold Spec; decide
