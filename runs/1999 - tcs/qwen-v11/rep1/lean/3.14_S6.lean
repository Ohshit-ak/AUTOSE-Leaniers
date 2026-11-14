import ContractForge
open ContractForge

-- 3.14/S6: Army Intelligence and Electronic Warfare Tactical Proficiency Trainer as an objective. [SSS493] The interactive courseware training capability for TCS shall be developed during Phase I and introduced to the user during scheduled demonstrations and tests. [SSS494] The training capability for performance of TCS functions shall include primary mission (flight route/payload) planning, mission control and monitoring, imagery processing, tactical communications, AV control communications and TCS system on line diagnostics. [SSS495] This capability will be qualified and improved during Phase I based upon use and feedback from qualified operators and users demonstrating TCS system equipment throughout Phase I.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  flightRoute : String
  payload     : String
  imagery     : String
  comm        : String
  avControl   : String
  diagnostics : String
  deriving DecidableEq, Repr

structure Output where
  primaryMission  : Bool
  missionControl  : Bool
  imageryProcessing : Bool
  tacticalComm    : Bool
  avComm          : Bool
  diagnosticsFunc : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.flightRoute ≠ "" ∧ i.payload ≠ "" ∧
                  i.imagery ≠ "" ∧ i.comm ≠ "" ∧ i.avControl ≠ "" ∧ i.diagnostics ≠ ""
  post := fun i o => (o.primaryMission = true ↔ i.flightRoute ≠ "" ∧ i.payload ≠ "") ∧
                     (o.missionControl = true ↔ i.flightRoute ≠ "" ∧ i.payload ≠ "") ∧
                     (o.imageryProcessing = true ↔ i.imagery ≠ "") ∧
                     (o.tacticalComm = true ↔ i.comm ≠ "") ∧
                     (o.avComm = true ↔ i.avControl ≠ "") ∧
                     (o.diagnosticsFunc = true ↔ i.diagnostics ≠ "") ∧
                     (o.primaryMission = false → o.missionControl = false) ∧
                     (o.missionControl = false → o.imageryProcessing = false) ∧
                     (o.imageryProcessing = false → o.tacticalComm = false) ∧
                     (o.tacticalComm = false → o.avComm = false) ∧
                     (o.avComm = false → o.diagnosticsFunc = false)

example : Spec.pre { flightRoute := "route1", payload := "payload1", imagery := "img1", 
                     comm := "comm1", avControl := "av1", diagnostics := "diag1" } ∧
          Spec.post { flightRoute := "route1", payload := "payload1", imagery := "img1", 
                      comm := "comm1", avControl := "av1", diagnostics := "diag1" }
                    { primaryMission := true, missionControl := true, imageryProcessing := true, 
                      tacticalComm := true, avComm := true, diagnosticsFunc := true } := by
  unfold Spec; decide
