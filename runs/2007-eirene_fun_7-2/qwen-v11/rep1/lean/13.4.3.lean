import ContractForge
open ContractForge

-- 13.4.3: 13.4.3 The confirmation message shall commence at the end of the call or if the radio moves out of the call area. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Call where
  duration : Nat
  deriving DecidableEq, Repr

structure Input where
  callActive : Bool
  radioMoved : Bool
  duration   : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmation : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callActive
  post := fun i o => o.confirmation = true ↔
    (i.callActive ∧ i.duration > 0) ∨ i.radioMoved

example : Spec.pre { callActive := true, radioMoved := false, duration := 10 } ∧
          Spec.post { callActive := true, radioMoved := false, duration := 10 }
                    { confirmation := true } := by
  unfold Spec; decide
