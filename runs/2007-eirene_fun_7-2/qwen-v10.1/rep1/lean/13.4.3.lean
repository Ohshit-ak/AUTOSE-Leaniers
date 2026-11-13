import ContractForge
open ContractForge

-- 13.4.3: 13.4.3 The confirmation message shall commence at the end of the call or if the radio moves out of the call area. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Call where
  callStarted : Bool
  deriving DecidableEq, Repr

structure Input where
  callStarted : Bool
  radioMoved  : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmationMessage : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callStarted
  post := fun i o => o.confirmationMessage = true ↔
    (i.callStarted = true ∧ i.radioMoved = false) ∨
    (i.callStarted = false ∧ i.radioMoved = true)

example : Spec.pre { callStarted := true, radioMoved := false } ∧ Spec.post { callStarted := true, radioMoved := false } { confirmationMessage := true } := by
  unfold Spec; decide
