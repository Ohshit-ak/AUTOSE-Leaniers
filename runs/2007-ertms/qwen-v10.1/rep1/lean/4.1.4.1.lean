import ContractForge
open ContractForge

-- 4.1.4.1: Partial Supervision shall be selected either by the Driver, or by information received from track-to-train transmission.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  driverSelection : Bool
  trackToTrain    : Bool
  deriving DecidableEq, Repr

structure Output where
  partialSupervision : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverSelection ∨ i.trackToTrain
  post := fun i o => o.partialSupervision = true ↔ (i.driverSelection ∨ i.trackToTrain)

example : Spec.pre { driverSelection := true, trackToTrain := false } ∧
          Spec.post { driverSelection := true, trackToTrain := false }
                    { partialSupervision := true } := by
  unfold Spec; decide
