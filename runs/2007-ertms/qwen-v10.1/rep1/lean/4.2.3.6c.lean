import ContractForge
open ContractForge

-- 4.2.3.6c: The target distance shall not be shown on the DMI unless selected by the driver.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  targetDistance : Option Nat
  deriving DecidableEq, Repr

structure Output where
  targetDistance : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.targetDistance = i.targetDistance

example : Spec.pre { targetDistance := none } ∧
          Spec.post { targetDistance := none } { targetDistance := none } := by
  unfold Spec; decide
