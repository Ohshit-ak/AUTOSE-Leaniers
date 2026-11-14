import ContractForge
open ContractForge

-- 3.3.3.3/S2: A relevant example of such a package is a general database management system (DBMS), where operational information such as schedules, logs, problem reports and maintenance information related to various pieces of equipment should be kept.Being in itself a distributed telescope system and having a large number of instruments, the Gemini 8m Telescopes system has internal communication needs
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  schedules   : List String
  logs        : List String
  problemReports : List String
  maintenanceInfo : List String
  deriving DecidableEq, Repr

structure Output where
  processedSchedules   : List String
  processedLogs        : List String
  processedProblemReports : List String
  processedMaintenanceInfo : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.schedules.Nodup ∧ i.logs.Nodup ∧ i.problemReports.Nodup ∧ i.maintenanceInfo.Nodup
  post := fun i o => (o.processedSchedules = i.schedules ∧
                      o.processedLogs = i.logs ∧
                      o.processedProblemReports = i.problemReports ∧
                      o.processedMaintenanceInfo = i.maintenanceInfo)

example : Spec.pre { schedules := ["2023-01-01", "2023-01-02"], logs := ["log1", "log2"], problemReports := [], maintenanceInfo := [] } ∧
          Spec.post { schedules := ["2023-01-01", "2023-01-02"], logs := ["log1", "log2"], problemReports := [], maintenanceInfo := [] }
                    { processedSchedules := ["2023-01-01", "2023-01-02"], processedLogs := ["log1", "log2"], processedProblemReports := [], processedMaintenanceInfo := [] } := by
  unfold Spec; decide
