import ContractForge
open ContractForge

-- 8.3.4/S1: Any group call controller who wishes to stop talking shall indicate his wish, for example by releasing the PTT button, whereupon the 3-digit DTMF sequence "#**" shall be transferred.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  pttReleased : Bool
  deriving DecidableEq, Repr

structure Output where
  muted : Bool
  dmfSequence : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.pttReleased
  post := fun i o => o.muted = true ∧
                     o.dmfSequence = "#**"

example : Spec.pre { pttReleased := true } ∧
          Spec.post { pttReleased := true }
                    { muted := true, dmfSequence := "#**" } := by
  unfold Spec; decide
