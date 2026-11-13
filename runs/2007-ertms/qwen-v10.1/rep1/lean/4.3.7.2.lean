import ContractForge
open ContractForge

-- 4.3.7.2: Within the braking curve area, a warning shall be given to the driver to enable him to react and avoid intervention from ETCS equipment at least 5 sec. before the intervention.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≥ 5000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 5000001 } := by
  unfold Spec; decide
