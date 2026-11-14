import ContractForge
open ContractForge

-- 3.2.2.1.1/S1: The TCS shall allow the operator to control an AV using the LOS as well as SATCOM data links. [SSS124] The TCS shall provide the necessary system capabilities required for AV flight control BLOS via uplink command to two MAE air vehicles. [SSS125] The TCS shall support operation of the AV via all flight modes, to include manual controls. [SSS126102] The TCS shall provide the capability to implement an emergency action plan, if supported by the AV, to control the AV during equipment failures. [SSS539] The TCS shall provide interactive displays necessary to command the flight of an AV. [SSS127]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mode : String
  actionPlan : Option String
  deriving DecidableEq, Repr

structure Output where
  controlMode : String
  emergencyAction : Bool
  interactiveDisplay : Bool
  deriving DecidableEq, Repr

-- IMPL: TCS uses LOS and SATCOM data links for AV control.
def Spec : Contract Input Output where
  pre  := fun i => i.mode ∈ ["manual", "BLOS", "emergency"] ∧
                   i.actionPlan.isSome ↔ i.mode = "emergency"
  post := fun i o => o.controlMode = i.mode ∧
                     o.emergencyAction = (i.mode = "emergency") ∧
                     o.interactiveDisplay = true ∧
                     (o.controlMode = "BLOS" → i.mode = "BLOS") ∧
                     (o.controlMode = "emergency" → i.mode = "emergency") ∧
                     (o.controlMode = "manual" → i.mode = "manual")

example : Spec.pre { mode := "BLOS", actionPlan := none } ∧ Spec.post { mode := "BLOS", actionPlan := none } { controlMode := "BLOS", emergencyAction := false, interactiveDisplay := true } := by
  unfold Spec; decide
