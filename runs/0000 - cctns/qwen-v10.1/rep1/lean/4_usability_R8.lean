import ContractForge
open ContractForge

-- 4/usability/R8: Minimizing navigation effort: The number of navigation steps needed to reach a certain piece of content should be minimized as long as different mental models, navigation strategies and tasks of the user are taken into account.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  navigationSteps : Nat
  deriving DecidableEq, Repr

structure Output where
  navigationSteps : Nat
  contentReached  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.navigationSteps
  post := fun i o => o.contentReached = true ↔
    i.navigationSteps = o.navigationSteps

example : Spec.pre { navigationSteps := 3 } ∧
          Spec.post { navigationSteps := 3 }
                    { contentReached := true, navigationSteps := 3 } := by
  unfold Spec; decide
