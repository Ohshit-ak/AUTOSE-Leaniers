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
  annotatedImage : String
  voiceReport : String
  textualReport : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.payloadData ≠ ""
  post := fun i o => (o.enhancedImage ≠ "" ↔ i.spotObjective = true) ∧
                     (o.annotatedImage ≠ "" ↔ i.missionObjective = true) ∧
                     (o.voiceReport ≠ "" ↔ i.spotObjective = true) ∧
                     (o.textualReport ≠ "" ↔ i.missionObjective = true)

example : Spec.pre { payloadData := "image", spotObjective := true, missionObjective := false } ∧
          Spec.post { payloadData := "image", spotObjective := true, missionObjective := false }
                    { enhancedImage := "enhanced", annotatedImage := "", voiceReport := "voice", textualReport := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { enhancedImage := if x.spotObjective then "enhanced" else "",
    annotatedImage := if x.missionObjective then "annotated" else "",
    voiceReport := if x.spotObjective then "voice" else "",
    textualReport := if x.missionObjective then "textual" else "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
