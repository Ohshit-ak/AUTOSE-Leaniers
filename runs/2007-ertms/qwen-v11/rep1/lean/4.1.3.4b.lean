import ContractForge
open ContractForge

-- 4.1.3.4b: Before authomatic transition to Shunting, ETCS shall request confirmation from the driver.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  driverConfirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  transitionConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverConfirmed
  post := fun i o => o.transitionConfirmed = true

example : Spec.pre { driverConfirmed := true } ∧
          Spec.post { driverConfirmed := true } { transitionConfirmed := true } := by
  unfold Spec; decide
