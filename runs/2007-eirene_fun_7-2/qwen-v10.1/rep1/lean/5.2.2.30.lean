import ContractForge
open ContractForge

-- 5.2.2.30: 5.2.2.30 At any time during the call, the lead driver shall be able to remove a member of the group. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure GroupMember where
  name : String
  deriving DecidableEq, Repr

structure Input where
  members : List GroupMember
  deriving DecidableEq, Repr

structure Output where
  members : List GroupMember
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.members.Nodup
  post := fun i o => o.members.length = i.members.length - 1 ∧
                     ∃ m ∈ i.members, o.members = i.members.filter (fun x => x ≠ m)

example : Spec.pre { members := [{ name := "Alice" }, { name := "Bob" }, { name := "Charlie" }] } ∧
          Spec.post { members := [{ name := "Alice" }, { name := "Bob" }, { name := "Charlie" }] }
                     { members := [{ name := "Alice" }, { name := "Bob" }] } := by
  unfold Spec; decide
