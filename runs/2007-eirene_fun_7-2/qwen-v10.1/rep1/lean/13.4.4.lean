import ContractForge
open ContractForge

-- 13.4.4: 13.4.4 If the radio loses contact with the network, the mechanism shall commence as soon as possible on regaining communications, for up to a maximum of 5 minutes without achieving contact. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 300000000

example : Spec.pre { } ∧ Spec.post { elapsedMicros := 299999999 } := by
  unfold Spec; decide
