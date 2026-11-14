import ContractForge
open ContractForge

-- REQ-1#3: Query times will take no longer than 5 seconds to any website.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros ≤ 5000000 ∧
                     (o.elapsedMicros = 0 → o.elapsedMicros = i.elapsedMicros)

example : Spec.pre { elapsedMicros := 0 } ∧ Spec.post { elapsedMicros := 0 } { elapsedMicros := 0 } := by
  unfold Spec; decide
