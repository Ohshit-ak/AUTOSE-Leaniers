import ContractForge
open ContractForge

-- 3.5.6.2/S3: Subsystems must be able to detect such danger and report it appropriately.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  dangerDetected : Bool
  reportSent     : Bool
  deriving DecidableEq, Repr

structure Output where
  dangerDetected : Bool
  reportSent     : Bool
  reportReceived : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dangerDetected = true
  post := fun i o => (o.dangerDetected = true ∧ o.reportSent = true ∧ o.reportReceived = true) ↔
                     (i.dangerDetected = true)

example : Spec.pre { dangerDetected := true, reportSent := false } ∧
          Spec.post { dangerDetected := true, reportSent := false }
                    { dangerDetected := true, reportSent := true, reportReceived := true } := by
  unfold Spec; decide
