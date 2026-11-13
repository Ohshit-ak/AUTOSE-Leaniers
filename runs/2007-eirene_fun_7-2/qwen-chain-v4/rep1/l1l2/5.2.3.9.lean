import ContractForge
open ContractForge

-- 5.2.3.9: 5.2.3.9 Switch off shall be soft so that the Cab radio completes the following housekeeping functions before actually switching off: (M) controlled termination of a current call; deregister train number (where applicable); store required data; confirmation of Railway emergency calls (see section 13).

-- L0 spec

structure Input where
  callActive : Bool
  trainNumberRegistered : Bool
  emergencyCallActive : Bool
  dataToStore : List String
  deriving DecidableEq, Repr

structure Output where
  callActive : Bool
  trainNumberRegistered : Bool
  emergencyCallActive : Bool
  dataToStore : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callActive = true ∨ ¬i.trainNumberRegistered ∨ ¬i.emergencyCallActive
  post := fun i o => (o.callActive = false ↔
    (i.callActive = true → (i.callActive = o.callActive ∧ i.trainNumberRegistered = o.trainNumberRegistered ∧
                            i.emergencyCallActive = o.emergencyCallActive ∧
                            i.dataToStore = o.dataToStore)) ∧
    (i.callActive = false → i.callActive = o.callActive ∧ i.trainNumberRegistered = o.trainNumberRegistered ∧
                             i.emergencyCallActive = o.emergencyCallActive ∧
                             i.dataToStore = o.dataToStore)) ∧
    (i.emergencyCallActive = true → o.emergencyCallActive = true)

example : Spec.pre { callActive := true, trainNumberRegistered := false, emergencyCallActive := true, dataToStore := ["data1", "data2"] } ∧ Spec.post { callActive := true, trainNumberRegistered := false, emergencyCallActive := true, dataToStore := ["data1", "data2"] } { callActive := true, trainNumberRegistered := false, emergencyCallActive := true, dataToStore := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  callActive : Bool
  trainNumberRegistered : Bool
  emergencyCallActive : Bool
  dataToStore : List String
  deriving DecidableEq, Repr

def ComputeMidContract : Contract Input Mid where
  pre  := fun i => i.callActive = true ∨ ¬i.trainNumberRegistered ∨ ¬i.emergencyCallActive
  post := fun i m => m.callActive = false ∧
    (i.callActive = true → (i.callActive = m.callActive ∧ i.trainNumberRegistered = m.trainNumberRegistered ∧
                            i.emergencyCallActive = m.emergencyCallActive ∧
                            i.dataToStore = m.dataToStore)) ∧
    (i.callActive = false → i.callActive = m.callActive ∧ i.trainNumberRegistered = m.trainNumberRegistered ∧
                             i.emergencyCallActive = m.emergencyCallActive ∧
                             i.dataToStore = m.dataToStore)

def FinalizeOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.callActive = m.callActive ∧
                     (o.trainNumberRegistered = true ↔ m.trainNumberRegistered = true) ∧
                     (o.emergencyCallActive = true ↔ m.emergencyCallActive = true) ∧
                     o.dataToStore = m.dataToStore
