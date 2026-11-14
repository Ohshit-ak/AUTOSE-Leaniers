import ContractForge
open ContractForge

-- 4/ease-of-use/R8: Frequently-executed System transactions must be designed so that they can be completed with a small number of interactions (e.g. mouse clicks).
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  derivedInteractions : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.derivedInteractions ≤ 3 ∧
                     (o.derivedInteractions = 0 ↔ o.derivedInteractions = 0) ∧
                     (o.derivedInteractions = 1 ↔ o.derivedInteractions = 1) ∧
                     (o.derivedInteractions = 2 ↔ o.derivedInteractions = 2)

example : Spec.pre {} ∧ Spec.post {} { derivedInteractions := 2 } := by
  unfold Spec; decide
