import ContractForge
open ContractForge

-- REQ-1#3: Query times will take no longer than 5 seconds to any website.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 5000000

example : Spec.pre { } ∧ Spec.post { } { elapsedMicros := 4999999 } := by
  unfold Spec; decide
