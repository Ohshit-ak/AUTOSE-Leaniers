import ContractForge
open ContractForge

-- 3.2.3.3/S1: The TCS shall have the functionality to conduct limited exploitation, to include voice and textual reporting for spot and mission objectives, on the payload product data. [SSS200] Limited exploitation, as a minimum, will include image enhancement and annotation.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { enhancedImage := if x.payloadData ≠ "" ∧ x.spotObjective ∨ x.missionObjective then "enhanced123" else "",
    annotation := if x.payloadData ≠ "" ∧ x.spotObjective ∨ x.missionObjective then "annotated123" else "",
    report := if x.payloadData ≠ "" ∧ x.spotObjective ∨ x.missionObjective then "report123" else "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
