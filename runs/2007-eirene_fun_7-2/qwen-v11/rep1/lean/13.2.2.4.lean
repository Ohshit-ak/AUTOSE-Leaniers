import ContractForge
open ContractForge

-- 13.2.2.4: 13.2.2.4 An audible indication of 5 seconds (to be confirmed by trials) shall be provided to originating and receiving users that the emergency function has been activated. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 5000000

example : Spec.pre { } ∧ Spec.post { elapsedMicros := 4999999 } := by
  unfold Spec; decide
