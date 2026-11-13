import ContractForge
open ContractForge

-- 3.12.1/S1: System documentation shall be developed as part of the TCS program and will follow MIL-STD-498 for format. [SSS427] The documentation developed shall contain sufficient level of detail to identify the functional, operational and design requirements of the TCS. [SSS428] The documentation shall contain sufficient technical detail to define the hardware and software design implemented to satisfy the system requirements. [SSS429] The TCS documentation shall include: [SSS430]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  documentation : String
  deriving DecidableEq, Repr

structure Output where
  documentation : String
  functional_requirements : String
  operational_requirements : String
  design_requirements : String
  hardware_design : String
  software_design : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.documentation ≠ ""
  post := fun i o => o.documentation = i.documentation ∧
                     o.functional_requirements ≠ "" ∧
                     o.operational_requirements ≠ "" ∧
                     o.design_requirements ≠ "" ∧
                     o.hardware_design ≠ "" ∧
                     o.software_design ≠ ""

example : Spec.pre { documentation := "TCS System Documentation" } ∧
          Spec.post { documentation := "TCS System Documentation",
                      functional_requirements := "Functional details",
                      operational_requirements := "Operational details",
                      design_requirements := "Design details",
                      hardware_design := "Hardware design details",
                      software_design := "Software design details" } := by
  unfold Spec; decide
