import ContractForge
open ContractForge

-- 5.2.2.24: 5.2.2.24 Once the call is terminated, the continuous visual alarm indication in the cab shall cease. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cabAlarm : Bool
  deriving DecidableEq, Repr

structure Output where
  cabAlarm : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabAlarm = true
  post := fun i o => o.cabAlarm = false

example : Spec.pre { cabAlarm := true } ∧ Spec.post { cabAlarm := true } { cabAlarm := false } := by
  unfold Spec; decide
