import ContractForge
open ContractForge

-- 3.15/S4: Exceptions shall be considered on a case by case basis. [SSS507] Each Service shall support the TCS as part of the UAV system which is organic to them. [SSS508] The TCS shall be maintained in accordance with the UAV ORD for that Service and the level of repair analysis for the hardware chosen. [SSS509] A TCS support and fielding package shall be developed and available for operational testing. [SSS510] The TCS shall be maintained in accordance with Services' approved UAV maintenance concepts and procedures. [SSS511] To the maximum extent possible, general purpose test equipment (GPTE) and common tools resident in each service shall be used to perform all corrective and preventative maintenance at all authorized levels of maintenance. [SSS512] Tools and test equipment required to maintain the TCS but not resident in each service inventory shall be identified as special tools and special purpose test equipment (SPTE), respectively, and kept to a minimum. [SSS513] The environmental support required by the TCS shall be at least the same as that required for the respective UAV System. [SSS514] Basing for the system will follow the plan for UAV units and service command echelon requirements as delineated in the ORD. [SSS515]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  service : String
  tcs     : String
  ord     : String
  levelOfRepair : String
  deriving DecidableEq, Repr

structure Output where
  supportPackage : String
  maintenancePlan : String
  tools : List String
  specialTools : List String
  environmentalSupport : String
  base : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.service ≠ "" ∧ i.tcs ≠ "" ∧ i.ord ≠ ""
  post := fun i o => 
    (o.supportPackage = "Developed and available for operational testing" ↔
     (i.service = "Service1" ∨ i.service = "Service2" ∨ i.service = "Service3")) ∧
    (o.maintenancePlan = "Maintained in accordance with Services' approved UAV maintenance concepts and procedures" ↔
     (i.service = "Service1" ∨ i.service = "Service2" ∨ i.service = "Service3")) ∧
    (o.tools.length ≤ 10 ∧
     o.tools.all (fun t => t = "General purpose test equipment" ∨ t = "Common tools")) ∧
    (o.specialTools.length ≤ 5 ∧
     o.specialTools.all (fun t => t = "Special tools" ∨ t = "Special purpose test equipment")) ∧
    (o.environmentalSupport = "At least the same as that required for the respective UAV System" ↔
     (i.service = "Service1" ∨ i.service = "Service2" ∨ i.service = "Service3")) ∧
    (o.base = "Basing for the system will follow the plan for UAV units and service command echelon requirements as delineated in the ORD" ↔
     (i.service = "Service1" ∨ i.service = "Service2" ∨ i.service = "Service3"))

example : Spec.pre { service := "Service1", tcs := "TCS1", ord := "ORD1" } ∧
          Spec.post { service := "Service1", tcs := "TCS1", ord := "ORD1" }
                    { supportPackage := "Developed and available for operational testing",
                      maintenancePlan := "Maintained in accordance with Services' approved UAV maintenance concepts and procedures",
                      tools := ["General purpose test equipment", "Common tools"],
                      specialTools := ["Special tools"],
                      environmentalSupport := "At least the same as that required for the respective UAV System",
                      base := "Basing for the system will follow the plan for UAV units and service command echelon requirements as delineated in the ORD" } := by
  unfold Spec; decide
