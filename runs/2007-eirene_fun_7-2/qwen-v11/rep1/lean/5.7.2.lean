import ContractForge
open ContractForge

-- 5.7.2: 5.7.2 The activation of the driver safety device shall automatically trigger the Cab radio to send a data message. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure CabRadio where
  dataSent : Bool
  deriving DecidableEq, Repr

structure DriverSafetyDevice where
  activated : Bool
  deriving DecidableEq, Repr

structure Input where
  cabRadio : CabRadio
  safetyDevice : DriverSafetyDevice
  deriving DecidableEq, Repr

structure Output where
  cabRadio : CabRadio
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.safetyDevice.activated = true
  post := fun i o => (o.cabRadio.dataSent = true ↔ i.cabRadio.dataSent = false)

example : Spec.pre { cabRadio := { dataSent := false }, safetyDevice := { activated := true } } ∧
          Spec.post { cabRadio := { dataSent := false }, safetyDevice := { activated := true } }
                    { cabRadio := { dataSent := true } } := by
  unfold Spec; decide
