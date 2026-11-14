import ContractForge
open ContractForge

-- 2.9.3/I1: The system must allow for fast transmission of rough images every 0.5 sec. This may be assisted through the use of data-loss compression techniques (e.g. JPEG, MPEG, etc).
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 500000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 490000 } := by
  unfold Spec; decide
