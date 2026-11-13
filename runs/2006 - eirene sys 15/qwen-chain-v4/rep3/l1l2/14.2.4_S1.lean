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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  shuntingLeaderRegistered : Bool
  shuntingMembersRegistered : List String
  deriving DecidableEq, Repr

def ComputeRegistrationContract : Contract Input Mid where
  pre  := fun i => i.shuntingModeOn = true
  post := fun i m => 
    m.shuntingLeaderRegistered = true ∧
    m.shuntingMembersRegistered.length = i.shuntingMembers.length ∧
    ∀ m ∈ i.shuntingMembers, m.shuntingMembersRegistered.contains m

def ActivateGroupCallContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    o.shuntingLeaderRegistered = m.shuntingLeaderRegistered ∧
    o.shuntingMembersRegistered = m.shuntingMembersRegistered ∧
    o.groupCallActive = true
