import ContractForge
open ContractForge

-- 2.6.3.1/S1: The Development Team shall perform weekly integrations of the [SYSTEM NAME] system and deploy these system updates to the Staging environment.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  week : Nat
  deriving DecidableEq, Repr

structure Output where
  deployed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.week % 1 = 0
  post := fun i o => o.deployed = true

example : Spec.pre { week := 7 } ∧ Spec.post { week := 7 } { deployed := true } := by
  unfold Spec; decide
