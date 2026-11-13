import ContractForge
open ContractForge

-- 13.2.2.3ii: 13.2.2.3ii After the 30 second period, if the connection was unsuccessful, the system shall provide another audible and visual indication that it was unable to connect the call. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  indication    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.indication = true ∧ o.elapsedMicros ≤ 30000000

example : Spec.pre {} ∧ Spec.post {} { indication := true, elapsedMicros := 29000000 } := by
  unfold Spec; decide
