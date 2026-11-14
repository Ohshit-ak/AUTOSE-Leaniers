import ContractForge
open ContractForge

-- 2.2.3/S1: The product must count and display the number of the user' asction.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  actionCount : Nat
  deriving DecidableEq, Repr

structure Output where
  actionCount : Nat
  displaying   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.actionCount = i.actionCount ∧
                     (o.displaying = true ↔ i.actionCount > 0)

example : Spec.pre { actionCount := 5 } ∧
          Spec.post { actionCount := 5 } { actionCount := 5, displaying := true } := by
  unfold Spec; decide
