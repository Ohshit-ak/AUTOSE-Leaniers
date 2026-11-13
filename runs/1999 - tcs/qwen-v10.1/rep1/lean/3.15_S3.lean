import ContractForge
open ContractForge

-- 3.15/S3: Support for the TCS shall be in accordance with the Integrated Logistical Support Plan (ILSP) and the maintenance concepts and policies of the individual Services. [SSS504] All TCS Operator Manuals and Technical Manuals shall be verified and validated prior to initial operational test. [SSS529] TCS transport and storage containers shall be reusable and enable the operators to set-up equipment within the established timelines in their ORDs. [SSS505] The TCS shall adhere to DoD regulations and policy governing military standards for logistics, Petroleum, Oil and Lubricants (POL), Test, Measurement, and Diagnostic Equipment (TMDE), tools, and other support items. [SSS506] Standard tools, TMDE, repair parts, and lubricants shall be used to maintain the TCS.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  operatorManuals : List String
  technicalManuals : List String
  transportContainers : List String
  storageContainers : List String
  tools : List String
  tmde : List String
  repairParts : List String
  lubricants : List String
  deriving DecidableEq, Repr

structure Output where
  verified : Bool
  validated : Bool
  reusable : Bool
  adheresToDoD : Bool
  usingStandardItems : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.operatorManuals.Nodup ∧ i.technicalManuals.Nodup ∧
                  i.transportContainers.Nodup ∧ i.storageContainers.Nodup ∧
                  i.tools.Nodup ∧ i.tmde.Nodup ∧ i.repairParts.Nodup ∧
                  i.lubricants.Nodup
  post := fun i o => o.verified = true ↔
                      i.operatorManuals.all (fun m => m ≠ "") ∧
                      i.technicalManuals.all (fun m => m ≠ "") ∧
                      i.transportContainers.all (fun c => c ≠ "") ∧
                      i.storageContainers.all (fun c => c ≠ "") ∧
                      o.validated = true ↔
                      i.operatorManuals.all (fun m => m ≠ "") ∧
                      i.technicalManuals.all (fun m => m ≠ "") ∧
                      o.reusable = true ↔
                      i.transportContainers.all (fun c => c ≠ "") ∧
                      i.storageContainers.all (fun c => c ≠ "") ∧
                      o.adheresToDoD = true ↔
                      i.transportContainers.all (fun c => c ≠ "") ∧
                      i.storageContainers.all (fun c => c ≠ "") ∧
                      i.tools.all (fun t => t ≠ "") ∧
                      i.tmde.all (fun t => t ≠ "") ∧
                      i.repairParts.all (fun p => p ≠ "") ∧
                      i.lubricants.all (fun l => l ≠ "") ∧
                      o.usingStandardItems = true ↔
                      i.tools.all (fun t => t ≠ "") ∧
                      i.tmde.all (fun t => t ≠ "") ∧
                      i.repairParts.all (fun p => p ≠ "") ∧
                      i.lubricants.all (fun l => l ≠ "")

example : Spec.pre { operatorManuals := ["OM1", "OM2"], technicalManuals := ["TM1", "TM2"],
                     transportContainers := ["TC1", "TC2"], storageContainers := ["SC1", "SC2"],
                     tools := ["T1", "T2"], tmde := ["TMDE1", "TMDE2"], repairParts := ["RP1", "RP2"],
                     lubricants := ["L1", "L2"] } ∧
          Spec.post { operatorManuals := ["OM1", "OM2"], technicalManuals := ["TM1", "TM2"],
                      transportContainers := ["TC1", "TC2"], storageContainers := ["SC1", "SC2"],
                      tools := ["T1", "T2"], tmde := ["TMDE1", "TMDE2"], repairParts := ["RP1", "RP2"],
                      lubricants := ["L1", "L2"] }
                    { verified := true, validated := true, reusable := true, adheresToDoD := true, usingStandardItems := true } := by
  unfold Spec; decide
