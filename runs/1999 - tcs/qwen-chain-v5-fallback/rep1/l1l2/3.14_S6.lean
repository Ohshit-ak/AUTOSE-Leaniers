import ContractForge
open ContractForge

-- 3.14/S6: Army Intelligence and Electronic Warfare Tactical Proficiency Trainer as an objective. [SSS493] The interactive courseware training capability for TCS shall be developed during Phase I and introduced to the user during scheduled demonstrations and tests. [SSS494] The training capability for performance of TCS functions shall include primary mission (flight route/payload) planning, mission control and monitoring, imagery processing, tactical communications, AV control communications and TCS system on line diagnostics. [SSS495] This capability will be qualified and improved during Phase I based upon use and feedback from qualified operators and users demonstrating TCS system equipment throughout Phase I.

-- L0 spec

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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { primaryMission := decide (x.flightRoute ≠ "" ∧ x.payload ≠ ""),
    missionControl := decide (x.flightRoute ≠ "" ∧ x.payload ≠ ""),
    imageryProcessing := decide (x.imagery ≠ ""),
    tacticalComm := decide (x.comm ≠ ""),
    avComm := decide (x.avControl ≠ ""),
    diagnosticsFunc := decide (x.diagnostics ≠ "") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
