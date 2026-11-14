import ContractForge
open ContractForge

-- 3.8.4/S1: The network shall send the SET-PARAMETER message with the attribute "D-ATT = F"3 [EN 301 515, Index [6]] to the mobile of the talking subscriber only if it has received the 3-digit sequence "#**" transmitted via DTMF from all the talking controllers4.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  dtmfSequence : String
  talkingControllers : List String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

-- IMPL: DTMF sequence processing

def Spec : Contract Input Output where
  pre  := fun i => i.dtmfSequence.length = 3 ∧ i.dtmfSequence.toList.all (fun c => c == '*')
  post := fun i o => o.sent = true ↔
    i.talkingControllers.length = 0 ∨
    (∀ c ∈ i.talkingControllers, i.dtmfSequence = "#**" ∧ o.sent = true)

example : Spec.pre { dtmfSequence := "***", talkingControllers := [] } ∧
          Spec.post { dtmfSequence := "***", talkingControllers := [] }
                    { sent := true } := by
  unfold Spec; decide
