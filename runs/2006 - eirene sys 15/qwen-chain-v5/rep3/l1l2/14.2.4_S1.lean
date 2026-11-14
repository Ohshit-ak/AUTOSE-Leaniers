import ContractForge
open ContractForge

-- 14.2.4/S1: After the "regular shunting mode ON" procedure has been completed, the procedures shown in table 14-2 and 14-3 shall be used to register the shunting leader and shunting members to a dedicated group call.

-- L0 spec

structure Input where
  shuntingModeOn : Bool
  shuntingLeader  : String
  shuntingMembers : List String
  deriving DecidableEq, Repr

structure Output where
  shuntingLeaderRegistered : Bool
  shuntingMembersRegistered : List String
  groupCallActive          : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shuntingModeOn = true
  post := fun i o => 
    o.shuntingLeaderRegistered = true ∧
    o.shuntingMembersRegistered.length = i.shuntingMembers.length ∧
    ∀ m ∈ i.shuntingMembers, o.shuntingMembersRegistered.contains m ∧
    o.groupCallActive = true

example : Spec.pre { shuntingModeOn := true, shuntingLeader := "Alice", shuntingMembers := ["Bob", "Charlie"] } ∧
          Spec.post { shuntingModeOn := true, shuntingLeader := "Alice", shuntingMembers := ["Bob", "Charlie"] }
                    { shuntingLeaderRegistered := true, shuntingMembersRegistered := ["Bob", "Charlie"], groupCallActive := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { shuntingLeaderRegistered := true,
    shuntingMembersRegistered := x.shuntingMembers,
    groupCallActive := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
