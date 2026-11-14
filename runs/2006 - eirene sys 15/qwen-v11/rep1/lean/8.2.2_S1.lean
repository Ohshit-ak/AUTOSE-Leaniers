import ContractForge
open ContractForge

-- 8.2.2/S1: To terminate a VGCS/VBS call by DTMF signalling, the 3-digit sequence "***" shall be used.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  dtmfSequence : String
  deriving DecidableEq, Repr

structure Output where
  terminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dtmfSequence.length = 3
  post := fun i o => o.terminated = true ↔ i.dtmfSequence = "***"

example : Spec.pre { dtmfSequence := "***" } ∧
          Spec.post { dtmfSequence := "***" }
                    { terminated := true } := by
  unfold Spec; decide
