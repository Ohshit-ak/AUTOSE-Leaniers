import ContractForge
open ContractForge

-- 4.9.9.1: The on board shall be capable of sending train data to the trackside after confirmation by the driver, or when entering the RBC area
-- compiles: True · rejects_bad_example: True · checked: True

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
    (i.enteringRBC → i.trainData.location ≠ "outside RBC area")

example : Spec.pre { driverConfirmed := true, enteringRBC := false,
                     trainData := { speed := 50, location := "inside RBC area" } } ∧
          Spec.post { driverConfirmed := true, enteringRBC := false,
                      trainData := { speed := 50, location := "inside RBC area" } }
                    { sentToTrackside := true } := by
  unfold Spec; decide
