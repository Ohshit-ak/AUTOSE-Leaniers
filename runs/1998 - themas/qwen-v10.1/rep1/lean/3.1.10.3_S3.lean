import ContractForge
open ContractForge

-- 3.1.10.3/S3: If the operational history report is selected, the THEMAS system shall select all the events from the event database, sort the events by date and time, and create the ASCII report file.
-- compiles: True · rejects_bad_example: True · checked: True

structure Event where
  date : String
  time : String
  description : String
  deriving DecidableEq, Repr

structure Input where
  selectedReport : String
  events : List Event
  deriving DecidableEq, Repr

structure Output where
  reportFile : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selectedReport = "operational history"
  post := fun i o => o.reportFile = "operational_history_report.txt" ∧
                     List.Pairwise (fun a b => a.date ≤ b.date ∧ a.time ≤ b.time) i.events

example : Spec.pre { selectedReport := "operational history", events := [] } ∧ Spec.post { selectedReport := "operational history", events := [] } { reportFile := "operational_history_report.txt" } := by
  unfold Spec; decide
