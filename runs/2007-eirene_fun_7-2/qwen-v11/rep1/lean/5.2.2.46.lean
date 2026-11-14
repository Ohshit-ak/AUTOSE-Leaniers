import ContractForge
open ContractForge

-- 5.2.2.46: 5.2.2.46 Once the driver has accepted the standard point-to-point call, it shall be connected appropriately, eg if the driver has accepted the call by lifting the handset, then the call shall be routed to the handset. (M) Receive incoming group or broadcast voice call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  driverAccepted : Bool
  handsetConnected : Bool
  deriving DecidableEq, Repr

structure Output where
  connected : Bool
  handsetConnected : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverAccepted = true
  post := fun i o => (o.connected = true ↔ i.handsetConnected = true) ∧
                     (o.handsetConnected = i.handsetConnected) ∧
                     (o.connected = true → o.handsetConnected = true)

example : Spec.pre { driverAccepted := true, handsetConnected := false } ∧
          Spec.post { driverAccepted := true, handsetConnected := false }
                    { connected := false, handsetConnected := false } := by
  unfold Spec; decide
