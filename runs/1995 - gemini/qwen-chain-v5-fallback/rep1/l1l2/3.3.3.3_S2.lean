import ContractForge
open ContractForge

-- 3.3.3.3/S2: A relevant example of such a package is a general database management system (DBMS), where operational information such as schedules, logs, problem reports and maintenance information related to various pieces of equipment should be kept.Being in itself a distributed telescope system and having a large number of instruments, the Gemini 8m Telescopes system has internal communication needs

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processedSchedules := x.schedules,
    processedLogs := x.logs,
    processedProblemReports := x.problemReports,
    processedMaintenanceInfo := x.maintenanceInfo }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
