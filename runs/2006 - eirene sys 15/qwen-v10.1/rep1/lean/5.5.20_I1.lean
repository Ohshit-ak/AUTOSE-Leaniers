import ContractForge
open ContractForge

-- 5.5.20/I1: an incoming call is received whilst the Cab radio is in an on-going call; (M)
-- compiles: True · rejects_bad_example: None · checked: False

structure Call where
  id : Nat
  status : String
  deriving DecidableEq, Repr

structure Input where
  ongoingCall : Call
  incomingCall : Call
  deriving DecidableEq, Repr

structure Output where
  ongoingCall : Call
  incomingCall : Call
  handling : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ongoingCall.status = "ongoing" ∧ i.incomingCall.status = "incoming"
  post := fun i o => (o.ongoingCall = i.ongoingCall ∧
                      o.incomingCall = i.incomingCall ∧
                      (o.handling = "merged" ↔
                       (o.ongoingCall.status = "merged" ∨ o.incomingCall.status = "merged"))) ∧
                     (o.ongoingCall.status = "ongoing" ∨ o.incomingCall.status = "incoming")

example : Spec.pre { ongoingCall := { id := 1, status := "ongoing" }, incomingCall := { id := 2, status := "incoming" } } ∧ Spec.post { ongoingCall := { id := 1, status := "ongoing" }, incomingCall := { id := 2, status := "incoming" } } { ongoingCall := { id := 1, status := "ongoing" }, incomingCall := { id := 2, status := "incoming" }, handling := "" } := by
  unfold Spec; decide
