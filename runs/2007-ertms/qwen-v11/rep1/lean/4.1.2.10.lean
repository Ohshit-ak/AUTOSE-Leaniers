import ContractForge
open ContractForge

-- 4.1.2.10: Current train data shall be stored (except at transition to shunting) in the ETCS equipment until the traction unit is not operative.
-- compiles: True · rejects_bad_example: True · checked: True

structure TrainData where
  id : Nat
  state : String
  deriving DecidableEq, Repr

structure DriverData where
  id : Nat
  state : String
  deriving DecidableEq, Repr

structure Input where
  trainData : Option TrainData
  driverData : Option DriverData
  tractionUnitOperative : Bool
  deriving DecidableEq, Repr

structure Output where
  trainData : Option TrainData
  driverData : Option DriverData
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainData ≠ none ∧ i.driverData ≠ none
  post := fun i o => (o.trainData = i.trainData ∧ o.driverData = i.driverData ∧
                      (o.trainData = none ∨ o.driverData = none) ↔
                      ¬i.tractionUnitOperative) ∧
                     (o.trainData = i.trainData →
                      (o.trainData = none ∨ o.trainData ≠ none ∧ i.trainData = none) ∧
                      (o.trainData = none ∨ o.trainData ≠ none ∧ i.trainData ≠ none →
                      i.trainData.getD { id := 0, state := "" } = o.trainData.getD { id := 0, state := "" })) ∧
                     (o.driverData = i.driverData →
                      (o.driverData = none ∨ o.driverData ≠ none ∧ i.driverData = none) ∧
                      (o.driverData = none ∨ o.driverData ≠ none ∧ i.driverData ≠ none →
                      i.driverData.getD { id := 0, state := "" } = o.driverData.getD { id := 0, state := "" }))

example : Spec.pre { trainData := some { id := 1, state := "active" }, driverData := some { id := 2, state := "active" }, tractionUnitOperative := true } ∧ Spec.post { trainData := some { id := 1, state := "active" }, driverData := some { id := 2, state := "active" }, tractionUnitOperative := true } { trainData := none, driverData := none } := by
  unfold Spec; decide
