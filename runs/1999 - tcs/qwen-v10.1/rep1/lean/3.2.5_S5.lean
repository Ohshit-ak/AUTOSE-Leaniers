import ContractForge
open ContractForge

-- 3.2.5/S5: The TCS shall have the capability to interoperate with a data server to receive, extract, and push intelligence data. [SSS212] The TCS shall have the capability to use cable to deliver live video imagery in multiple locations. [SSS213] The TCS shall have the ability to interface with Service specific ground and airborne Ultra High Frequency (UHF), Very High Frequency (VHF), UHF/VHF, and High Frequency (HF) radios for digital message transmission while using the same radios for record traffic. [SSS214] Record traffic is defined as operational/voice communications.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  dataServer : String
  videoCables : List String
  radios : List String
  deriving DecidableEq, Repr

structure Output where
  receivedData : Bool
  liveVideo : Bool
  interfacedRadios : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dataServer ≠ "" ∧ i.videoCables.Nodup ∧ i.radios.Nodup
  post := fun i o => o.receivedData = true ∧
                     o.liveVideo = true ∧
                     o.interfacedRadios = true

example : Spec.pre { dataServer := "server1", videoCables := ["cable1", "cable2"], radios := ["radio1", "radio2"] } ∧
          Spec.post { dataServer := "server1", videoCables := ["cable1", "cable2"], radios := ["radio1", "radio2"] }
                    { receivedData := true, liveVideo := true, interfacedRadios := true } := by
  unfold Spec; decide
