import ContractForge
open ContractForge

-- 5.7.4: 5.7.4 DSD alarm information shall be transmitted to the primary controller. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  alarmInfo : String
  deriving DecidableEq, Repr

structure Output where
  primaryController : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.primaryController = i.alarmInfo

example : Spec.pre { alarmInfo := "DSD alarm" } ∧
          Spec.post { alarmInfo := "DSD alarm" } { primaryController := "DSD alarm" } := by
  unfold Spec; decide
