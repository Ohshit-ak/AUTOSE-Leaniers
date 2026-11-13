import ContractForge
open ContractForge

-- 4.9.9.1: The on board shall be capable of sending train data to the trackside after confirmation by the driver, or when entering the RBC area

-- L0 spec

structure TrainData where
  speed   : Nat
  location: String
  deriving DecidableEq, Repr

structure Input where
  driverConfirmed : Bool
  enteringRBC     : Bool
  trainData       : TrainData
  deriving DecidableEq, Repr

structure Output where
  sentToTrackside : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverConfirmed ∨ i.enteringRBC
  post := fun i o => o.sentToTrackside ↔
    (i.driverConfirmed → i.trainData.speed ≤ 100) ∧
    (i.enteringRBC → i.trainData.location ≠ "outsideRBC")

example : Spec.pre { driverConfirmed := true, enteringRBC := false,
                     trainData := { speed := 50, location := "insideRBC" } } ∧
          Spec.post { driverConfirmed := true, enteringRBC := false,
                      trainData := { speed := 50, location := "insideRBC" } }
                    { sentToTrackside := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sentToTrackside := 
    (x.driverConfirmed → x.trainData.speed ≤ 100) ∧
    (x.enteringRBC → x.trainData.location ≠ "outsideRBC") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
