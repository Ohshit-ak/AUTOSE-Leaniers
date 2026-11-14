import ContractForge
open ContractForge

-- 3.8.2/S1: The network shall send the SET-PARAMETER message with the attribute "D-ATT = T"1 [EN 301 515, Index [6]] to the mobile station of the talking subscriber if it receives the 3- digit sequence "###" transmitted via DTMF or the group call SETUP message2 from a controller terminal.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  sequence : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

-- IMPL: The network sends the SET-PARAMETER message with the attribute "D-ATT = T" to the mobile station.

def Spec : Contract Input Output where
  pre  := fun i => i.sequence.length = 3 ∧ i.sequence.toList.all Char.isDigit = true
  post := fun i o => o.sent = true ↔
    (i.sequence = "###" ∨
     (∃ msg ∈ [i.sequence], msg = "group call SETUP message" ∧
      ∃ ctrl ∈ [i.sequence], ctrl = "controller terminal"))

example : Spec.pre { sequence := "111" } ∧ Spec.post { sequence := "111" } { sent := false } := by
  unfold Spec; decide
