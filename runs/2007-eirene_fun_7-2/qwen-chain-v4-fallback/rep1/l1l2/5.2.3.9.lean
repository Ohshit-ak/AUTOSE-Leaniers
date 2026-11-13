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

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { callActive := false,
    trainNumberRegistered := x.trainNumberRegistered,
    emergencyCallActive := x.emergencyCallActive,
    dataToStore := x.dataToStore }
