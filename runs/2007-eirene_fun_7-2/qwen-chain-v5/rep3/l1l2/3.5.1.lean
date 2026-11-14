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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  callType : String
  participants : List String
  deriving DecidableEq, Repr

def ComputeParticipantsContract : Contract Input Mid where
  pre  := fun i => i.callType = "group" ∨ i.callType = "broadcast"
  post := fun i m => m.callType = i.callType ∧
                     (m.participants = i.fixedUsers ↔
                      (i.callType = "group" ∧ m.participants.length = i.fixedUsers.length)) ∧
                     (i.callType = "broadcast" → m.participants.length = i.fixedUsers.length)

def FinalizeCallTypeContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.callType = m.callType ∧
                     (o.participants = m.participants) ∧
                     (o.callType = "broadcast" → o.participants.length = m.participants.length)



theorem po1 : Contract.Compatible ComputeParticipantsContract FinalizeCallTypeContract := by
  discharge_po1 [ComputeParticipantsContract, FinalizeCallTypeContract, Spec]

theorem po2 : Contract.Refines (ComputeParticipantsContract.seq FinalizeCallTypeContract) Spec := by
  discharge_po2 [ComputeParticipantsContract, FinalizeCallTypeContract, Spec]

-- L2 ComputeParticipantsContract (success=False)

def ComputeParticipantsContractImpl (x : Input) : Mid :=
  { callType := x.callType,
    participants := if x.callType = "group" then x.fixedUsers else [] }

-- L2 FinalizeCallTypeContract (success=True)

def FinalizeCallTypeContractImpl (x : Mid) : Output :=
  { callType := x.callType,
    participants := x.participants }

theorem FinalizeCallTypeContractImpl_ok : FinalizeCallTypeContract.Satisfies FinalizeCallTypeContractImpl := by
  discharge_po3 [FinalizeCallTypeContract, FinalizeCallTypeContractImpl]
