import ContractForge
open ContractForge

-- 5.2.3.31: 5.2.3.31 The driver of the previously registered train shall be informed (by audible and visual indications) that his train number has been overridden by another driver. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Train where
  trainNumber : Nat
  driver      : String
  deriving DecidableEq, Repr

structure Input where
  previousTrain : Option Train
  newTrain      : Train
  deriving DecidableEq, Repr

structure Output where
  previousTrain : Option Train
  newTrain      : Train
  driverNotified : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.previousTrain.isSome
  post := fun i o => o.previousTrain = i.previousTrain ∧
                     o.newTrain = i.newTrain ∧
                     (o.driverNotified = true ↔
                      i.previousTrain.getD { trainNumber := 0, driver := "" } ≠ i.newTrain ∧
                      i.previousTrain.getD { trainNumber := 0, driver := "" }.trainNumber = i.newTrain.trainNumber)

example : Spec.pre { previousTrain := some { trainNumber := 10, driver := "John" },
                     newTrain := { trainNumber := 10, driver := "Jane" } } ∧
          Spec.post { previousTrain := some { trainNumber := 10, driver := "John" },
                      newTrain := { trainNumber := 10, driver := "Jane" } }
                    { previousTrain := some { trainNumber := 10, driver := "John" },
                      newTrain := { trainNumber := 10, driver := "Jane" },
                      driverNotified := true } := by
  unfold Spec; decide
