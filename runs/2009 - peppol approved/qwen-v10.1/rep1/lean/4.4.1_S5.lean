import ContractForge
open ContractForge

-- 4.4.1/S5: The conformance to PEPPOL's WP2 interoperability standards will be approached by following the project agreed roadmap that includes the design and management of a dynamic knowledge base, known as the pre-VCD mapping tool and by implementing VCD services that conform to a multi-stage approach.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  roadmap : String
  preVCDMappingTool : String
  vcdServices : List String
  deriving DecidableEq, Repr

structure Output where
  conformance : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.roadmap ≠ "" ∧ i.preVCDMappingTool ≠ "" ∧ i.vcdServices.Nodup
  post := fun i o => o.conformance = true ↔
    (i.roadmap.contains "dynamic knowledge base" ∧
     i.roadmap.contains "pre-VCD mapping tool" ∧
     i.vcdServices.all (fun s => s.contains "conform to a multi-stage approach"))

example : Spec.pre { roadmap := "Project roadmap includes dynamic knowledge base and pre-VCD mapping tool.", 
                     preVCDMappingTool := "Developing pre-VCD mapping tool.", 
                     vcdServices := ["VCD service 1", "VCD service 2"] } ∧
          Spec.post { roadmap := "Project roadmap includes dynamic knowledge base and pre-VCD mapping tool.", 
                      preVCDMappingTool := "Developing pre-VCD mapping tool.", 
                      vcdServices := ["VCD service 1", "VCD service 2"] }
                    { conformance := true } := by
  unfold Spec; decide
