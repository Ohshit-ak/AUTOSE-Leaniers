import ContractForge
open ContractForge

-- 4.1.3.2a: Transfer to Shunting on driver's selection shall only be possible when stationary.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  stationary : Bool
  deriving DecidableEq, Repr

structure Output where
  transferred : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.stationary
  post := fun i o => o.transferred = i.stationary

example : Spec.pre { stationary := true } ∧
          Spec.post { stationary := true } { transferred := true } := by
  unfold Spec; decide
