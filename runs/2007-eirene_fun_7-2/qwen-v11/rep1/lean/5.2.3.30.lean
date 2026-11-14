import ContractForge
open ContractForge

-- 5.2.3.30: 5.2.3.30 A means to override the currently registered train number shall be provided to the newly registering driver. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure TrainNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Driver where
  id      : Nat
  trainNo : Option TrainNumber
  deriving DecidableEq, Repr

structure Input where
  driverId   : Nat
  newTrainNo : Option TrainNumber
  currentTrainNo : Option TrainNumber
  deriving DecidableEq, Repr

structure Output where
  driverId   : Nat
  newTrainNo : Option TrainNumber
  currentTrainNo : Option TrainNumber
  overriding : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverId ≠ 0
  post := fun i o => (o.driverId = i.driverId ∧
                      o.newTrainNo = i.newTrainNo ∧
                      o.currentTrainNo = i.currentTrainNo ∧
                      o.overriding = (o.newTrainNo ≠ i.currentTrainNo))

example : Spec.pre { driverId := 1, newTrainNo := some { number := 5 }, currentTrainNo := some { number := 5 } } ∧ Spec.post { driverId := 1, newTrainNo := some { number := 5 }, currentTrainNo := some { number := 5 } } { driverId := 1, newTrainNo := some { number := 5 }, currentTrainNo := some { number := 5 }, overriding := false } := by
  unfold Spec; decide
