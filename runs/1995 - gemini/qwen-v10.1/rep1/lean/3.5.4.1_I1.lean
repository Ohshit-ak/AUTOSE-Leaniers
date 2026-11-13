import ContractForge
open ContractForge

-- 3.5.4.1/I1: Monitor level Each subsystem should have a background task running whenever that subsystem is operational, performing such tasks as checking power supply levels, temperatures, performance, correct responses to commands. The OCS is to be notified of any detected problems.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  subsystemOperational : Bool
  powerSupplyLevel     : Nat
  temperature          : Nat
  performance          : Nat
  commandResponse      : Bool
  deriving DecidableEq, Repr

structure Output where
  subsystemOperational : Bool
  powerSupplyLevel     : Nat
  temperature          : Nat
  performance          : Nat
  commandResponse      : Bool
  problemDetected      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subsystemOperational
  post := fun i o => o.subsystemOperational = i.subsystemOperational ∧
                     o.powerSupplyLevel = i.powerSupplyLevel ∧
                     o.temperature = i.temperature ∧
                     o.performance = i.performance ∧
                     o.commandResponse = i.commandResponse ∧
                     (o.problemDetected = true ↔
                      (i.powerSupplyLevel ≤ 50 ∨
                       i.temperature ≥ 80 ∨
                       i.performance ≤ 50 ∨
                       ¬i.commandResponse))

example : Spec.pre { subsystemOperational := true, powerSupplyLevel := 45, temperature := 75, performance := 60, commandResponse := true } ∧ Spec.post { subsystemOperational := true, powerSupplyLevel := 45, temperature := 75, performance := 60, commandResponse := true } { subsystemOperational := true, powerSupplyLevel := 45, temperature := 75, performance := 60, commandResponse := true, problemDetected := true } := by
  unfold Spec; decide
