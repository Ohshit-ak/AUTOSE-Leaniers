import ContractForge
open ContractForge

-- 3.10.1/S1: The TCS hardware will provide the functionality and capability to receive, process, and disseminate video and telemetry data from the AV and payload; perform mission planning; monitor and control the payload; monitor and control the AV; and monitor and control the data links.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  videoData  : String
  telemetry  : String
  missionPlan: String
  payload    : String
  av         : String
  dataLinks  : String
  deriving DecidableEq, Repr

structure Output where
  processedVideoData  : String
  processedTelemetry  : String
  missionPlanExecuted : Bool
  payloadControlled   : Bool
  avControlled        : Bool
  dataLinksControlled : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.videoData ≠ "" ∧ i.telemetry ≠ "" ∧
                  i.missionPlan ≠ "" ∧ i.payload ≠ "" ∧
                  i.av ≠ "" ∧ i.dataLinks ≠ ""
  post := fun i o => o.processedVideoData = i.videoData ∧
                     o.processedTelemetry = i.telemetry ∧
                     o.missionPlanExecuted = true ∧
                     o.payloadControlled = true ∧
                     o.avControlled = true ∧
                     o.dataLinksControlled = true

example : Spec.pre { videoData := "data1", telemetry := "data2", missionPlan := "plan1", payload := "payload1", av := "av1", dataLinks := "links1" } ∧
          Spec.post { videoData := "data1", telemetry := "data2", missionPlan := "plan1", payload := "payload1", av := "av1", dataLinks := "links1" }
                    { processedVideoData := "data1", processedTelemetry := "data2", missionPlanExecuted := true, payloadControlled := true, avControlled := true, dataLinksControlled := true } := by
  unfold Spec; decide
