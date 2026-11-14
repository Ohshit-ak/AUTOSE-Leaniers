import ContractForge
open ContractForge

-- 10.4.2: 10.4.2 Activating a group on the mobile shall allow a user to receive a call from that group. (M)

-- L0 spec

structure Group where
  name : String
  id   : Nat
  deriving DecidableEq, Repr

structure Input where
  groups   : List Group
  groupIds : List Nat
  userId   : Nat
  deriving DecidableEq, Repr

structure Output where
  userId   : Nat
  groups   : List Group
  calling  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userId ≠ 0 ∧ i.groupIds.Nodup
  post := fun i o => o.userId = i.userId ∧
                     (o.calling = true ↔
                      ∃ gid ∈ i.groupIds, ∃ g ∈ i.groups, g.id = gid)

example : Spec.pre { groups := [{ name := "Group1", id := 1 }, { name := "Group2", id := 2 }],
                     groupIds := [1, 2], userId := 5 } ∧
          Spec.post { groups := [{ name := "Group1", id := 1 }, { name := "Group2", id := 2 }],
                      groupIds := [1, 2], userId := 5 }
                    { userId := 5, groups := [{ name := "Group1", id := 1 }, { name := "Group2", id := 2 }],
                      calling := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { userId := x.userId,
    groups := x.groups,
    calling := decide (∃ gid ∈ x.groupIds, ∃ g ∈ x.groups, g.id = gid) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
