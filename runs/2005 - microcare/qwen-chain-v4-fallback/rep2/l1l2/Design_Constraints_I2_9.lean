import ContractForge
open ContractForge

-- Design Constraints/I2#9: The system should have the provision to create any number of individual user under any user group. Each Individual User should have the following information Group Name (Selecting from User Group) User Name Password Verify Password

-- L0 spec

structure UserGroup where
  name : String
  deriving DecidableEq, Repr

structure IndividualUser where
  groupName : String
  userName  : String
  password  : String
  verifyPassword : String
  deriving DecidableEq, Repr

structure Input where
  userGroups : List UserGroup
  individualUser : IndividualUser
  deriving DecidableEq, Repr

structure Output where
  created : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.individualUser.groupName ∈ i.userGroups.map (·.name)
  post := fun i o =>
    (o.created = true ↔
      i.individualUser.userName ≠ "" ∧
      i.individualUser.password = i.individualUser.verifyPassword ∧
      i.individualUser.groupName ∈ i.userGroups.map (·.name))

example : Spec.pre { userGroups := [{ name := "Admin" }],
                     individualUser := { groupName := "Admin", userName := "user1", password := "pass", verifyPassword := "pass" } } ∧
          Spec.post { userGroups := [{ name := "Admin" }],
                      individualUser := { groupName := "Admin", userName := "user1", password := "pass", verifyPassword := "pass" } }
                    { created := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { created := 
      x.individualUser.userName ≠ "" ∧
      x.individualUser.password = x.individualUser.verifyPassword ∧
      x.individualUser.groupName ∈ x.userGroups.map (·.name) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
