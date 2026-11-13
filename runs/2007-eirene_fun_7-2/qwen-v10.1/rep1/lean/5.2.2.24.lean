import ContractForge
open ContractForge

-- 5.2.2.24: 5.2.2.24 Once the call is terminated, the continuous visual alarm indication in the cab shall cease. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  cabAlarm : Bool
  callTerminated : Bool
  deriving DecidableEq, Repr

structure Output where
  cabAlarm : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callTerminated
  post := fun i o => o.cabAlarm ↔ i.cabAlarm ∧ i.callTerminated

example : Spec.pre { cabAlarm := true, callTerminated := true } ∧ Spec.post { cabAlarm := true, callTerminated := true } { cabAlarm := true } := by
  unfold Spec; decide
