import ContractForge
open ContractForge

-- 5.2.2.46: 5.2.2.46 Once the driver has accepted the standard point-to-point call, it shall be connected appropriately, eg if the driver has accepted the call by lifting the handset, then the call shall be routed to the handset. (M) Receive incoming group or broadcast voice call
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  driverConnected : Bool
  handsetLifted   : Bool
  deriving DecidableEq, Repr

structure Output where
  connectedTo : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverConnected
  post := fun i o => (o.connectedTo = "handset" ↔ i.handsetLifted) ∧
                     (o.connectedTo = "handset" → i.driverConnected)

example : Spec.pre { driverConnected := true, handsetLifted := false } ∧ Spec.post { driverConnected := true, handsetLifted := false } { connectedTo := "" } := by
  unfold Spec; decide
