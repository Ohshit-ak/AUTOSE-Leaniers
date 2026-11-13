import ContractForge
open ContractForge

-- 3.5.1: 3.5.1 Where fixed network users are involved in a group or broadcast call, fixed network users will be pre-defined and will not change during the course of the call. (I)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callType : String
  fixedUsers : List String
  deriving DecidableEq, Repr

structure Output where
  callType : String
  participants : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callType = "group" ∨ i.callType = "broadcast"
  post := fun i o => o.callType = i.callType ∧
                     o.participants = i.fixedUsers

example : Spec.pre { callType := "broadcast", fixedUsers := ["user1", "user2"] } ∧
          Spec.post { callType := "broadcast", fixedUsers := ["user1", "user2"] }
                    { callType := "broadcast", participants := ["user1", "user2"] } := by
  unfold Spec; decide
