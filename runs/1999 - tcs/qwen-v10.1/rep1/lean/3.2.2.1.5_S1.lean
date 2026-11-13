import ContractForge
open ContractForge

-- 3.2.2.1.5/S1: TCS shall provide the capability to monitor specific telemetry elements real-time, and record all telemetry elements for future review and processing. [SSS140] TCS shall provide the capability to monitor AV adherence to the uplinked mission plan, detecting any deviations greater than 10% from projected flight path, and notifying the operator if deviations are detected. [SSS141] TCS shall provide the capability to monitor the status of all AV subsystems reporting status. [SSS142]
-- compiles: False · rejects_bad_example: None · checked: False

structure TelemetryElement where
  name   : String
  value  : Nat
  deriving DecidableEq, Repr

structure Input where
  telemetryElements : List TelemetryElement
  missionPlan      : List TelemetryElement
  subsystemStatus  : List TelemetryElement
  deriving DecidableEq, Repr

structure Output where
  monitoredElements : List TelemetryElement
  deviationsDetected : Bool
  subsystemStatuses  : List TelemetryElement
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.telemetryElements.Nodup ∧ i.missionPlan.Nodup ∧ i.subsystemStatus.Nodup
  post := fun i o =>
    (∀ te ∈ o.monitoredElements, te ∈ i.telemetryElements) ∧
    (o.deviationsDetected = true ↔
      ∃ te ∈ i.missionPlan, (te.value - (i.telemetryElements.find? (·.name = te.name).get!).value) / (i.telemetryElements.find? (·.name = te.name).get!).value > 0.1) ∧
    (∀ ss ∈ o.subsystemStatuses, ss ∈ i.subsystemStatus)

example : Spec.pre { telemetryElements := [{ name := "speed", value := 500 },
                                            { name := "altitude", value := 10000 }],
                     missionPlan := [{ name := "speed", value := 550 },
                                     { name := "altitude", value := 10500 }],
                     subsystemStatus := [{ name := "engine", value := 100 },
                                         { name := "battery", value := 80 }] } ∧
          Spec.post { telemetryElements := [{ name := "speed", value := 500 },
                                             { name := "altitude", value := 10000 }],
                      missionPlan := [{ name := "speed", value := 550 },
                                      { name := "altitude", value := 10500 }],
                      subsystemStatus := [{ name := "engine", value := 100 },
                                          { name := "battery", value := 80 }] }
                    { monitoredElements := [{ name := "speed", value := 500 },
                                            { name := "altitude", value := 10000 }],
                      deviationsDetected := false,
                      subsystemStatuses := [{ name := "engine", value := 100 },
                                            { name := "battery", value := 80 }] } := by
  unfold Spec; decide
