import ContractForge
open ContractForge

-- 7.2.2.14: 7.2.2.14 Where available, the functional identity of the calling party shall be displayed. (M) Receive incoming group or broadcast voice call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callerId : String
  callType : String -- "group" or "broadcast"
  deriving DecidableEq, Repr

structure Output where
  callerId : String
  callType : String -- "group" or "broadcast"
  display  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callType = "group" ∨ i.callType = "broadcast"
  post := fun i o => o.callType = i.callType ∧ o.callerId = i.callerId ∧
                     (o.display = true ↔ i.callType = "group" ∨ i.callType = "broadcast")

example : Spec.pre { callerId := "Alice", callType := "group" } ∧
          Spec.post { callerId := "Alice", callType := "group" }
                     { callerId := "Alice", callType := "group", display := true } := by
  unfold Spec; decide
