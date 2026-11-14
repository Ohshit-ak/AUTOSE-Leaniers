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
                     o.participants = i.fixedUsers

example : Spec.pre { callType := "broadcast", fixedUsers := ["user1", "user2"] } ∧
          Spec.post { callType := "broadcast", fixedUsers := ["user1", "user2"] }
                    { callType := "broadcast", participants := ["user1", "user2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callType := x.callType,
    participants := x.fixedUsers }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
