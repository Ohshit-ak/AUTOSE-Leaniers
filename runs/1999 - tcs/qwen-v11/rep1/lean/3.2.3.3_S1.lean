import ContractForge
open ContractForge

-- 3.2.3.3/S1: The TCS shall have the functionality to conduct limited exploitation, to include voice and textual reporting for spot and mission objectives, on the payload product data. [SSS200] Limited exploitation, as a minimum, will include image enhancement and annotation.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  payloadData : String
  spotObjective : Bool
  missionObjective : Bool
  deriving DecidableEq, Repr

structure Output where
  enhancedImage : String
  annotation : String
  report : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.payloadData ≠ ""
  post := fun i o => (o.enhancedImage ≠ "" ↔ i.payloadData ≠ "" ∧ i.spotObjective ∨ i.missionObjective) ∧
                     (o.annotation ≠ "" ↔ i.payloadData ≠ "" ∧ i.spotObjective ∨ i.missionObjective) ∧
                     (o.report ≠ "" ↔ i.payloadData ≠ "" ∧ i.spotObjective ∨ i.missionObjective)

example : Spec.pre { payloadData := "image123", spotObjective := true, missionObjective := false } ∧
          Spec.post { payloadData := "image123", spotObjective := true, missionObjective := false }
                    { enhancedImage := "enhanced123", annotation := "annotated123", report := "report123" } := by
  unfold Spec; decide
