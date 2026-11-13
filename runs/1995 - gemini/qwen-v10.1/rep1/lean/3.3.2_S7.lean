import ContractForge
open ContractForge

-- 3.3.2/S7: Microprocessor software in particular tends to contain hardware specific software, though one should try to keep it as hardware independent as possible, isolating different software layers.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  hardwareSpecific : Bool
  deriving DecidableEq, Repr

structure Output where
  hardwareIndependent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.hardwareSpecific
  post := fun i o => o.hardwareIndependent = true

example : Spec.pre { hardwareSpecific := true } ∧
          Spec.post { hardwareSpecific := true } { hardwareIndependent := true } := by
  unfold Spec; decide
