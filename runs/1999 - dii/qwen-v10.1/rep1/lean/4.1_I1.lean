import ContractForge
open ContractForge

-- 4.1/I1: Environmental Mode: This is the real-time operations that must react to varying degrees of readiness to full scale wartime operations such as crisis planning with the use of heterogeneous data types and sources, transfer capabilities, data management services.
-- compiles: True · rejects_bad_example: True · checked: True

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
