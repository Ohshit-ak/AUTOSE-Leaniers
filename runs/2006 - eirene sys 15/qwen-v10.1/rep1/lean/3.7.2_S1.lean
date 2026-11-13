import ContractForge
open ContractForge

-- 3.7.2/S1: The network shall terminate the ongoing VGCS/VBS call if it receives the 3-digit sequence "***" transmitted via DTMF signals.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  dtmfSequence : String
  deriving DecidableEq, Repr

structure Output where
  terminated : Bool
  deriving DecidableEq, Repr

-- IMPL: The network checks for the 3-digit sequence "***" in the DTMF signals.
def Spec : Contract Input Output where
  pre  := fun i => i.dtmfSequence.length = 3
  post := fun i o => o.terminated = true ↔ i.dtmfSequence = "***"

example : Spec.pre { dtmfSequence := "***" } ∧
          Spec.post { dtmfSequence := "***" } { terminated := true } := by
  unfold Spec; decide
