import ContractForge
open ContractForge

-- 4.1.3.4b: Before authomatic transition to Shunting, ETCS shall request confirmation from the driver.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  driverConfirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  driverConfirmed : Bool
  shuntingStarted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverConfirmed = false
  post := fun i o => (o.driverConfirmed = i.driverConfirmed ∧
                      o.shuntingStarted = false) ↔
                    (o.driverConfirmed = true ∧
                     o.shuntingStarted = true)

example : Spec.pre { driverConfirmed := false } ∧
          Spec.post { driverConfirmed := false }
                     { driverConfirmed := true, shuntingStarted := false } := by
  unfold Spec; decide
