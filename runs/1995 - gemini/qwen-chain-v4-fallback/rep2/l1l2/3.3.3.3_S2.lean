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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processed := x.schedules.length + x.logs.length + x.problemReports.length + x.maintenanceInfo.length > 0 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
