import ContractForge
open ContractForge

-- 3.10.3/S1: The TCS software will provide the functionality and capability to receive, process, and disseminate video and telemetry data from the AV and payload; perform mission planning; monitor and control the payload; monitor and control the AV; and monitor and control the data links.

-- L0 spec

structure Input where
  videoData  : List String
  telemetry  : List String
  missionPlan : String
  deriving DecidableEq, Repr

structure Output where
  processedVideoData  : List String
  processedTelemetry  : List String
  missionPlanStatus   : String
  payloadStatus       : String
  avStatus            : String
  dataLinksStatus     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.videoData.Nodup ∧ i.telemetry.Nodup ∧ i.missionPlan ≠ ""
  post := fun i o => o.processedVideoData = i.videoData ∧
                     o.processedTelemetry = i.telemetry ∧
                     (o.missionPlanStatus = "planned" ↔ i.missionPlan ≠ "") ∧
                     (o.payloadStatus = "monitored" ↔ true) ∧
                     (o.avStatus = "controlled" ↔ true) ∧
                     (o.dataLinksStatus = "monitored" ↔ true)

example : Spec.pre { videoData := ["vid1", "vid2"], telemetry := ["tel1", "tel2"], missionPlan := "plan1" } ∧
          Spec.post { videoData := ["vid1", "vid2"], telemetry := ["tel1", "tel2"], missionPlan := "plan1" }
                    { processedVideoData := ["vid1", "vid2"], processedTelemetry := ["tel1", "tel2"], missionPlanStatus := "planned", payloadStatus := "monitored", avStatus := "controlled", dataLinksStatus := "monitored" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processedVideoData := x.videoData,
    processedTelemetry := x.telemetry,
    missionPlanStatus := if x.missionPlan ≠ "" then "planned" else "not planned",
    payloadStatus := "monitored",
    avStatus := "controlled",
    dataLinksStatus := "monitored" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
