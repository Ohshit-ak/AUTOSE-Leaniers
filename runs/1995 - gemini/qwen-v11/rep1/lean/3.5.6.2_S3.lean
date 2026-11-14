import ContractForge
open ContractForge

-- 3.5.6.2/S3: Subsystems must be able to detect such danger and report it appropriately.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  subsystemStatus : String
  dangerDetected  : Bool
  deriving DecidableEq, Repr

structure Output where
  dangerReported : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subsystemStatus ≠ "" ∧ i.dangerDetected
  post := fun i o => o.dangerReported = true ∧
                     (o.dangerReported = i.dangerDetected)

example : Spec.pre { subsystemStatus := "OK", dangerDetected := true } ∧
          Spec.post { subsystemStatus := "OK", dangerDetected := true }
                    { dangerReported := true } := by
  unfold Spec; decide
