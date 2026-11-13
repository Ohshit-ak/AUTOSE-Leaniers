import ContractForge
open ContractForge

-- 5.2.3.30: 5.2.3.30 A means to override the currently registered train number shall be provided to the newly registering driver. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure TrainNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Driver where
  trainNumber : Option TrainNumber
  deriving DecidableEq, Repr

structure Input where
  currentTrainNumber : Option TrainNumber
  newDriver          : Driver
  override           : Bool
  deriving DecidableEq, Repr

structure Output where
  newTrainNumber : Option TrainNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.override = true ∨ i.currentTrainNumber = i.newDriver.trainNumber
  post := fun i o => (o.newTrainNumber = i.currentTrainNumber ↔ i.override = true) ∧
                     (o.newTrainNumber = i.newDriver.trainNumber ↔ i.override = false)

example : Spec.pre { currentTrainNumber := none, newDriver := { trainNumber := some { number := 12345 } }, override := true } ∧ Spec.post { currentTrainNumber := none, newDriver := { trainNumber := some { number := 12345 } }, override := true } { newTrainNumber := none } := by
  unfold Spec; decide
