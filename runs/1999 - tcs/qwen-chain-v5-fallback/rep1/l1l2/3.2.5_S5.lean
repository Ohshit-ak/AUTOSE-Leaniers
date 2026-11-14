import ContractForge
open ContractForge

-- 3.2.5/S5: The TCS shall have the capability to interoperate with a data server to receive, extract, and push intelligence data. [SSS212] The TCS shall have the capability to use cable to deliver live video imagery in multiple locations. [SSS213] The TCS shall have the ability to interface with Service specific ground and airborne Ultra High Frequency (UHF), Very High Frequency (VHF), UHF/VHF, and High Frequency (HF) radios for digital message transmission while using the same radios for record traffic. [SSS214] Record traffic is defined as operational/voice communications.

-- L0 spec

structure Input where
  dataServer : String
  videoCables : List String
  radios : List String
  liveVideo : Bool
  interfacedRadios : Bool
  deriving DecidableEq, Repr

structure Output where
  receivedData : Bool
  liveVideo : Bool
  interfacedRadios : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dataServer ≠ "" ∧ i.videoCables.Nodup ∧ i.radios.Nodup
  post := fun i o => (o.receivedData = true ↔
    i.dataServer ≠ "" ∧
    (∃ v ∈ i.videoCables, o.liveVideo = true) ∧
    (∃ r ∈ i.radios, o.interfacedRadios = true)) ∧
    (o.liveVideo = true ↔
    ∃ v ∈ i.videoCables, o.liveVideo = true) ∧
    (o.interfacedRadios = true ↔
    ∃ r ∈ i.radios, o.interfacedRadios = true)

example : Spec.pre { dataServer := "server1", videoCables := ["cable1", "cable2"], radios := ["radio1", "radio2"], liveVideo := true, interfacedRadios := true } ∧
          Spec.post { dataServer := "server1", videoCables := ["cable1", "cable2"], radios := ["radio1", "radio2"], liveVideo := true, interfacedRadios := true }
                    { receivedData := true, liveVideo := true, interfacedRadios := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { receivedData := decide (x.dataServer ≠ "" ∧ x.videoCables.any (fun v => x.videoCables.contains v) ∧ x.radios.any (fun r => x.radios.contains r)),
    liveVideo := x.videoCables.any (fun v => x.videoCables.contains v),
    interfacedRadios := x.radios.any (fun r => x.radios.contains r) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
