import ContractForge
open ContractForge

-- 5.2.3.30: 5.2.3.30 A means to override the currently registered train number shall be provided to the newly registering driver. (M)

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  overriding : Bool
  driverId : Nat
  deriving DecidableEq, Repr

def UpdateDriverContract : Contract Input Mid where
  pre  := fun i => i.driverId ≠ 0
  post := fun i m => ((m.overriding = (i.newTrainNo ≠ i.currentTrainNo))) ∧ m.driverId = i.driverId

def FinalizeOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.driverId = m.driverId ∧
                      o.newTrainNo = m.driverId.bind (fun d => d.newTrainNo) (fun _ => none) ∧
                      o.currentTrainNo = m.driverId.bind (fun d => d.currentTrainNo) (fun _ => none) ∧
                      o.overriding = m.overriding)


