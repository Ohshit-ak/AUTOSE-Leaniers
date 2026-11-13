import ContractForge
open ContractForge

-- 5.2.2.30: 5.2.2.30 At any time during the call, the lead driver shall be able to remove a member of the group. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { members := x.members.filter (fun m => m.name = "Alice" || m.name = "Bob" || m.name = "Charlie") }
