import ContractForge
open ContractForge

-- 13.3.1: 13.3.1 Authorised EIRENE mobiles shall be able to receive a Railway emergency call at any time while the mobile is powered up. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  poweredUp : Bool
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.poweredUp
  post := fun i o => o.received = true

example : Spec.pre { poweredUp := true } ∧ Spec.post { poweredUp := true } { received := true } := by
  unfold Spec; decide
