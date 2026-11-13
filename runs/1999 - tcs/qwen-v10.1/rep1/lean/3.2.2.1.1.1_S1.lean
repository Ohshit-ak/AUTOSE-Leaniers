import ContractForge
open ContractForge

-- 3.2.2.1.1.1/S1: The TCS shall allow the operator to command the flight behavior characteristics inherent to the selected AV. [SSS128] The operator shall have the capability to initiate as well as change, to include as a minimum manual override, flight behaviors by sending the proper control commands to the UAV. [SSS129]
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  flightBehavior : String
  manualOverride : Bool
  controlCommands : List String
  deriving DecidableEq, Repr

structure Output where
  flightBehavior : String
  manualOverride : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.controlCommands.length > 0
  post := fun i o => o.flightBehavior = i.flightBehavior ∧
                     o.manualOverride = i.manualOverride ∧
                     (i.manualOverride → o.flightBehavior = "manual") ∧
                     (¬i.manualOverride → o.flightBehavior = i.flightBehavior) ∧
                     (∀ c ∈ i.controlCommands, o.flightBehavior = "manual" →
                      (c = "override" → o.flightBehavior = "manual") ∧
                      (c ≠ "override" → o.flightBehavior = "auto"))

example : Spec.pre { flightBehavior := "auto", manualOverride := false,
                     controlCommands := ["start", "override"] } ∧
          Spec.post { flightBehavior := "auto", manualOverride := false,
                      controlCommands := ["start", "override"] }
                    { flightBehavior := "auto", manualOverride := false } := by
  unfold Spec; decide
