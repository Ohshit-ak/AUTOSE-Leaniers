import ContractForge
open ContractForge

-- 5.2.3.9: 5.2.3.9 Switch off shall be soft so that the Cab radio completes the following housekeeping functions before actually switching off: (M) controlled termination of a current call; deregister train number (where applicable); store required data; confirmation of Railway emergency calls (see section 13).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callActive : Bool
  currentCall : Option String
  trainNumber : Option String
  dataToStore : List String
  emergencyCallConfirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  callActive : Bool
  currentCall : Option String
  trainNumber : Option String
  dataToStore : List String
  emergencyCallConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callActive = true
  post := fun i o => (o.callActive = false ↔
    (i.callActive = true ∧
     (i.currentCall = none ↔ o.emergencyCallConfirmed = true) ∧
     (i.trainNumber = none ∨ o.trainNumber = none) ∧
     o.dataToStore.Nodup ∧
     o.dataToStore = i.dataToStore))

example : Spec.pre { callActive := true, currentCall := none, trainNumber := none,
                     dataToStore := ["data1", "data2"], emergencyCallConfirmed := true } ∧
          Spec.post { callActive := true, currentCall := none, trainNumber := none,
                      dataToStore := ["data1", "data2"], emergencyCallConfirmed := true }
                    { callActive := false, currentCall := none, trainNumber := none,
                      dataToStore := ["data1", "data2"], emergencyCallConfirmed := true } := by
  unfold Spec; decide
