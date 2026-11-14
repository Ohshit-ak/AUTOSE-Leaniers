import ContractForge
open ContractForge

-- 3.10.1/S1: The TCS hardware will provide the functionality and capability to receive, process, and disseminate video and telemetry data from the AV and payload; perform mission planning; monitor and control the payload; monitor and control the AV; and monitor and control the data links.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  videoData : List String
  telemetryData : List String
  missionPlan : String
  payloadStatus : String
  avStatus : String
  dataLinks : List String
  deriving DecidableEq, Repr

structure Output where
  processedVideoData : List String
  processedTelemetryData : List String
  missionPlanStatus : String
  payloadControlStatus : String
  avControlStatus : String
  dataLinkControlStatus : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.videoData.Nodup ∧ i.telemetryData.Nodup ∧ i.missionPlan ≠ "" ∧
                   i.payloadStatus ≠ "" ∧ i.avStatus ≠ "" ∧ i.dataLinks.Nodup
  post := fun i o => o.processedVideoData = i.videoData ∧
                     o.processedTelemetryData = i.telemetryData ∧
                     o.missionPlanStatus = "planned" ∧
                     o.payloadControlStatus = "controlled" ∧
                     o.avControlStatus = "controlled" ∧
                     o.dataLinkControlStatus = "controlled"

example : Spec.pre { videoData := ["vid1", "vid2"], telemetryData := ["tel1", "tel2"],
                     missionPlan := "plan1", payloadStatus := "status1",
                     avStatus := "status2", dataLinks := ["link1", "link2"] } ∧
          Spec.post { videoData := ["vid1", "vid2"], telemetryData := ["tel1", "tel2"],
                      missionPlan := "plan1", payloadStatus := "status1",
                      avStatus := "status2", dataLinks := ["link1", "link2"] }
                    { processedVideoData := ["vid1", "vid2"], processedTelemetryData := ["tel1", "tel2"],
                      missionPlanStatus := "planned", payloadControlStatus := "controlled",
                      avControlStatus := "controlled", dataLinkControlStatus := "controlled" } := by
  unfold Spec; decide
