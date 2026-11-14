import ContractForge
open ContractForge

-- 2.13.2/S3: In the case of IOC failure, no transfer of control to another IOC will be possible, due to the local connections and interfaces to the control electronics.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  iocFailed : Bool
  controlPossible : Bool
  deriving DecidableEq, Repr

structure Output where
  controlPossible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.iocFailed ∧ i.controlPossible = false
  post := fun i o => o.controlPossible = false

example : Spec.pre { iocFailed := true, controlPossible := false } ∧
          Spec.post { iocFailed := true, controlPossible := false } { controlPossible := false } := by
  unfold Spec; decide
