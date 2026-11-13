import ContractForge
open ContractForge

-- 7.2.2.14: 7.2.2.14 Where available, the functional identity of the calling party shall be displayed. (M) Receive incoming group or broadcast voice call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callerId : String
  deriving DecidableEq, Repr

structure Output where
  callerId : String
  displayed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callerId ≠ ""
  post := fun i o => o.displayed = true ∧ o.callerId = i.callerId

example : Spec.pre { callerId := "Radio1" } ∧
          Spec.post { callerId := "Radio1" }
                    { displayed := true, callerId := "Radio1" } := by
  unfold Spec; decide
