import ContractForge
open ContractForge

-- 5.5.20/I1: an incoming call is received whilst the Cab radio is in an on-going call; (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  onGoingCall : Bool
  incomingCall : Bool
  deriving DecidableEq, Repr

structure Output where
  onGoingCall : Bool
  incomingCall : Bool
  handling : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.onGoingCall = true ∧ i.incomingCall = true
  post := fun i o => (o.onGoingCall = i.onGoingCall ∧
                      o.incomingCall = i.incomingCall ∧
                      o.handling = true)

example : Spec.pre { onGoingCall := true, incomingCall := true } ∧
          Spec.post { onGoingCall := true, incomingCall := true }
                    { onGoingCall := true, incomingCall := true, handling := true } := by
  unfold Spec; decide
