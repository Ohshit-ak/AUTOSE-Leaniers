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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { driverId := x.driverId,
    newTrainNo := x.newTrainNo,
    currentTrainNo := x.currentTrainNo,
    overriding := (x.newTrainNo ≠ x.currentTrainNo) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
