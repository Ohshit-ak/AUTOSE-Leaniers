import ContractForge
open ContractForge

-- 3.5.1: 3.5.1 Where fixed network users are involved in a group or broadcast call, fixed network users will be pre-defined and will not change during the course of the call. (I)

-- L0 spec

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
                     (o.participants = i.fixedUsers ↔
                      (i.callType = "group" ∧ o.participants.length = i.fixedUsers.length)) ∧
                     (o.callType = "broadcast" → o.participants.length = i.fixedUsers.length)

example : Spec.pre { callType := "group", fixedUsers := ["user1", "user2"] } ∧ Spec.post { callType := "group", fixedUsers := ["user1", "user2"] } { callType := "group", participants := ["user1", "user2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { callType := x.callType,
    participants := if x.callType = "group" then x.fixedUsers else x.fixedUsers }
