import ContractForge
open ContractForge

-- 3.15/S4: Exceptions shall be considered on a case by case basis. [SSS507] Each Service shall support the TCS as part of the UAV system which is organic to them. [SSS508] The TCS shall be maintained in accordance with the UAV ORD for that Service and the level of repair analysis for the hardware chosen. [SSS509] A TCS support and fielding package shall be developed and available for operational testing. [SSS510] The TCS shall be maintained in accordance with Services' approved UAV maintenance concepts and procedures. [SSS511] To the maximum extent possible, general purpose test equipment (GPTE) and common tools resident in each service shall be used to perform all corrective and preventative maintenance at all authorized levels of maintenance. [SSS512] Tools and test equipment required to maintain the TCS but not resident in each service inventory shall be identified as special tools and special purpose test equipment (SPTE), respectively, and kept to a minimum. [SSS513] The environmental support required by the TCS shall be at least the same as that required for the respective UAV System. [SSS514] Basing for the system will follow the plan for UAV units and service command echelon requirements as delineated in the ORD. [SSS515]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  service : String
  tcs     : String
  ord     : String
  levelOfRepair : String
  deriving DecidableEq, Repr

structure Output where
  supportPackage : Bool
  maintenancePlan : Bool
  toolsAndTestEquipment : Bool
  environmentalSupport : Bool
  basingPlan : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => 
    o.supportPackage = true ∧
    o.maintenancePlan = (i.ord ≠ "" ∧ i.levelOfRepair ≠ "") ∧
    o.toolsAndTestEquipment = (i.service = "Air Force" ∨ i.service = "Navy") ∧
    o.environmentalSupport = (i.service = "Air Force" ∨ i.service = "Navy") ∧
    o.basingPlan = (i.service = "Air Force" ∨ i.service = "Navy")

example : Spec.pre { service := "Air Force", tcs := "TCS123", ord := "ORD456", levelOfRepair := "Level1" } ∧
          Spec.post { service := "Air Force", tcs := "TCS123", ord := "ORD456", levelOfRepair := "Level1" }
                    { supportPackage := true, maintenancePlan := true, toolsAndTestEquipment := true, environmentalSupport := true, basingPlan := true } := by
  unfold Spec; decide
