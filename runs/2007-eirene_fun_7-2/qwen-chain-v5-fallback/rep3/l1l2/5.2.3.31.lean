import ContractForge
open ContractForge

-- 5.2.3.31: 5.2.3.31 The driver of the previously registered train shall be informed (by audible and visual indications) that his train number has been overridden by another driver. (M)

-- L0 spec

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
                      i.previousTrain.getD { trainNumber := 0, driver := "" } ≠
                      { trainNumber := i.newTrain.trainNumber, driver := o.newTrain.driver })

example : Spec.pre { previousTrain := some { trainNumber := 10, driver := "John" },
                     newTrain := { trainNumber := 10, driver := "Jane" } } ∧
          Spec.post { previousTrain := some { trainNumber := 10, driver := "John" },
                      newTrain := { trainNumber := 10, driver := "Jane" } }
                    { previousTrain := some { trainNumber := 10, driver := "John" },
                      newTrain := { trainNumber := 10, driver := "Jane" },
                      driverNotified := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { previousTrain := x.previousTrain,
    newTrain := x.newTrain,
    driverNotified := decide (x.previousTrain.getD { trainNumber := 0, driver := "" } ≠ { trainNumber := x.newTrain.trainNumber, driver := x.newTrain.driver }) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
