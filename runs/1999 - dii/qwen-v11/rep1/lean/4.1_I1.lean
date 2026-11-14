import ContractForge
open ContractForge

-- 4.1/I1: Environmental Mode: This is the real-time operations that must react to varying degrees of readiness to full scale wartime operations such as crisis planning with the use of heterogeneous data types and sources, transfer capabilities, data management services.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  readiness : Nat
  crisisPlanning : Bool
  transferCapabilities : Nat
  dataManagement : Nat
  deriving DecidableEq, Repr

structure Output where
  environmentalMode : Bool
  readiness : Nat
  crisisPlanning : Bool
  transferCapabilities : Nat
  dataManagement : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.readiness > 0
  post := fun i o => o.environmentalMode ↔
    (i.readiness > 0) ∧
    (o.crisisPlanning = i.crisisPlanning) ∧
    (o.transferCapabilities = i.transferCapabilities) ∧
    (o.dataManagement = i.dataManagement) ∧
    (o.readiness = i.readiness) ∧
    (o.environmentalMode = true ↔
      (i.crisisPlanning = true) ∧
      (i.transferCapabilities > 0) ∧
      (i.dataManagement > 0))

example : Spec.pre { readiness := 50, crisisPlanning := true, transferCapabilities := 100, dataManagement := 80 } ∧
          Spec.post { readiness := 50, crisisPlanning := true, transferCapabilities := 100, dataManagement := 80 }
                    { environmentalMode := true, readiness := 50, crisisPlanning := true, transferCapabilities := 100, dataManagement := 80 } := by
  unfold Spec; decide
