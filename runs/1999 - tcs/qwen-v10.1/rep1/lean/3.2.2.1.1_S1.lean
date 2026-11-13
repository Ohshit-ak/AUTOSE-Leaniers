import ContractForge
open ContractForge

-- 3.2.2.1.1/S1: The TCS shall allow the operator to control an AV using the LOS as well as SATCOM data links. [SSS124] The TCS shall provide the necessary system capabilities required for AV flight control BLOS via uplink command to two MAE air vehicles. [SSS125] The TCS shall support operation of the AV via all flight modes, to include manual controls. [SSS126102] The TCS shall provide the capability to implement an emergency action plan, if supported by the AV, to control the AV during equipment failures. [SSS539] The TCS shall provide interactive displays necessary to command the flight of an AV. [SSS127]
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  mode : String
  actionPlan : Option String
  deriving DecidableEq, Repr

structure Output where
  controlMode : String
  actionPlanSupported : Bool
  deriving DecidableEq, Repr

-- IMPL: Uses a flight control algorithm to manage the AV based on the provided mode and action plan.
def Spec : Contract Input Output where
  pre  := fun i => i.mode ∈ ["manual", "auto", "emergency"] ∧
                   (i.actionPlan = none ∨ i.actionPlan.getD "not supported" = "supported")
  post := fun i o => o.controlMode = i.mode ∧
                     o.actionPlanSupported = (i.actionPlan = some "supported")

example : Spec.pre { mode := "manual", actionPlan := some "supported" } ∧
          Spec.post { mode := "manual", actionPlan := some "supported" }
                    { controlMode := "manual", actionPlanSupported := true } := by
  unfold Spec; decide
