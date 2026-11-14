import ContractForge
open ContractForge

-- Design Constraints/I4#8: The system should not allow the user to create a User Group and Individual User with existing names

-- L0 spec

structure UserGroup where
  name : String
  deriving DecidableEq, Repr

structure IndividualUser where
  name : String
  deriving DecidableEq, Repr

structure Input where
  userGroups : List UserGroup
  individualUsers : List IndividualUser
  newGroupName : String
  newUserName : String
  deriving DecidableEq, Repr

structure Output where
  newGroupCreated : Bool
  newUserNameValid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o =>
    (o.newGroupCreated = false ↔ ∃ g ∈ i.userGroups, g.name = i.newGroupName) ∧
    (o.newUserNameValid = false ↔ ∃ u ∈ i.individualUsers, u.name = i.newUserName)

example : Spec.pre { userGroups := [{ name := "Admin" }],
                     individualUsers := [{ name := "Alice" }],
                     newGroupName := "Admin",
                     newUserName := "Alice" } ∧
          Spec.post { userGroups := [{ name := "Admin" }],
                      individualUsers := [{ name := "Alice" }],
                      newGroupName := "Admin",
                      newUserName := "Alice" }
                    { newGroupCreated := false, newUserNameValid := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { newGroupCreated := decide (¬ (∃ g ∈ x.userGroups, g.name = x.newGroupName)),
    newUserNameValid := decide (¬ (∃ u ∈ x.individualUsers, u.name = x.newUserName)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
