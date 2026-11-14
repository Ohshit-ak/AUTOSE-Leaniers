import ContractForge
open ContractForge

-- 4.1.8.1: Unfitted operation shall be possible if ordered by trackside
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  ordered : Bool
  deriving DecidableEq, Repr

structure Output where
  operationPossible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ordered
  post := fun i o => o.operationPossible = i.ordered

example : Spec.pre { ordered := true } ∧
          Spec.post { ordered := true } { operationPossible := true } := by
  unfold Spec; decide
