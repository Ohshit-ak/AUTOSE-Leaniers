import ContractForge
open ContractForge

-- 8.3.2/S1: A group call controller who wishes to start talking (except in the case of an originator, a joiner or a re-joiner speaking for the first time5) shall indicate his wish, for example by pressing the PTT button, whereupon the 3-digit DTMF sequence "###" shall be transferred.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callerType : String
  pressingPTT : Bool
  deriving DecidableEq, Repr

structure Output where
  muting : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callerType ≠ "originator" ∧
                   i.callerType ≠ "joiner" ∧
                   i.callerType ≠ "re-joiner" ∧
                   i.pressingPTT = true
  post := fun i o => (o.muting = true ↔ i.callerType = "speaker" ∧ i.pressingPTT = true) ∧
                     (o.muting = false → i.callerType = "speaker" ∧ i.pressingPTT = false)

example : Spec.pre { callerType := "speaker", pressingPTT := true } ∧
          Spec.post { callerType := "speaker", pressingPTT := true }
                    { muting := true } := by
  unfold Spec; decide
