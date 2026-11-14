import ContractForge
open ContractForge

-- 5.2.2.30: 5.2.2.30 At any time during the call, the lead driver shall be able to remove a member of the group. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure GroupMember where
  id : Nat
  deriving DecidableEq, Repr

structure Input where
  leadDriver : Nat
  members    : List GroupMember
  deriving DecidableEq, Repr

structure Output where
  leadDriver : Nat
  members    : List GroupMember
  removed    : Option GroupMember
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.leadDriver ∈ i.members.map (·.id)
  post := fun i o => o.leadDriver = i.leadDriver ∧
                     o.removed.isSome ↔
                     ∃ m ∈ i.members, m.id = i.leadDriver ∧
                     o.members.length = i.members.length - 1 ∧
                     o.members.contains m = false

example : Spec.pre { leadDriver := 2, members := [{ id := 1 }, { id := 2 }, { id := 3 }] } ∧
          Spec.post { leadDriver := 2, members := [{ id := 1 }, { id := 2 }, { id := 3 }],
                      removed := some { id := 2 } } := by
  unfold Spec; decide
