import ContractForge
open ContractForge

-- 3.8.3/S1: When the network has detected the 3-digit DTMF sequence "###" transmitted via DTMF from a controller terminal and if the controller was not previously talking it should indicate its recognition by playing a single DTMF grant tone "#" of duration of 100ms ± 5ms to be sent to that controller terminal only.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  dtmfSequence : String
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  grantToneSent : Bool
  deriving DecidableEq, Repr

-- IMPL: DTMF detection and grant tone sending

def Spec : Contract Input Output where
  pre  := fun i => i.dtmfSequence = "###" ∧ i.dtmfSequence.length = 3
  post := fun i o => o.grantToneSent = true ∧
                      (o.elapsedMicros ≤ 100000) ∧
                      (o.elapsedMicros ≤ 5000)

example : Spec.pre { dtmfSequence := "###" } ∧
          Spec.post { dtmfSequence := "###", elapsedMicros := 95000, grantToneSent := true } := by
  unfold Spec; decide
