import ContractForge
open ContractForge

-- 3.3.3.3/S2: A relevant example of such a package is a general database management system (DBMS), where operational information such as schedules, logs, problem reports and maintenance information related to various pieces of equipment should be kept.Being in itself a distributed telescope system and having a large number of instruments, the Gemini 8m Telescopes system has internal communication needs
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  schedules   : List String
  logs        : List String
  problemReports : List String
  maintenanceInfo : List String
  deriving DecidableEq, Repr

structure Output where
  processed   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.schedules.Nodup ∧ i.logs.Nodup ∧ i.problemReports.Nodup ∧ i.maintenanceInfo.Nodup
  post := fun i o => o.processed = true ↔
    (i.schedules.length + i.logs.length + i.problemReports.length + i.maintenanceInfo.length > 0)

example : Spec.pre { schedules := ["2023-01-01", "2023-01-02"], logs := ["2023-01-01"], problemReports := [], maintenanceInfo := [] } ∧
          Spec.post { schedules := ["2023-01-01", "2023-01-02"], logs := ["2023-01-01"], problemReports := [], maintenanceInfo := [] }
                    { processed := true } := by
  unfold Spec; decide
