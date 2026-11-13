import ContractForge
open ContractForge

-- 4.1/I1: Environmental Mode: This is the real-time operations that must react to varying degrees of readiness to full scale wartime operations such as crisis planning with the use of heterogeneous data types and sources, transfer capabilities, data management services.

-- L0 spec

structure Input where
  readiness : Nat
  crisisPlanning : Bool
  transferCapabilities : Bool
  dataManagement : Bool
  deriving DecidableEq, Repr

structure Output where
  environmentalMode : Bool
  readinessUpdated : Nat
  crisisPlanningResult : Bool
  transferCapabilitiesResult : Bool
  dataManagementResult : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.readiness ∧ i.readiness ≤ 100
  post := fun i o =>
    o.environmentalMode = true ↔
    (o.readinessUpdated = i.readiness ∧
     o.crisisPlanningResult = i.crisisPlanning ∧
     o.transferCapabilitiesResult = i.transferCapabilities ∧
     o.dataManagementResult = i.dataManagement)

example : Spec.pre { readiness := 50, crisisPlanning := true, transferCapabilities := false, dataManagement := true } ∧
          Spec.post { readiness := 50, crisisPlanning := true, transferCapabilities := false, dataManagement := true }
                    { environmentalMode := true, readinessUpdated := 50, crisisPlanningResult := true, transferCapabilitiesResult := false, dataManagementResult := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { environmentalMode := true,
    readinessUpdated := x.readiness,
    crisisPlanningResult := x.crisisPlanning,
    transferCapabilitiesResult := x.transferCapabilities,
    dataManagementResult := x.dataManagement }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
