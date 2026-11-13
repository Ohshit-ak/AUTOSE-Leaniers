import ContractForge
open ContractForge

-- Design Constraints/I4#8: The system should not allow the user to create a User Group and Individual User with existing names
-- compiles: True · rejects_bad_example: True · checked: True

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
  createdGroup : Option UserGroup
  createdUser : Option IndividualUser
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newGroupName ≠ "" ∧ i.newUserName ≠ ""
  post := fun i o =>
    (o.createdGroup = some { name := i.newGroupName } ↔
      ¬ ∃ g ∈ i.userGroups, g.name = i.newGroupName) ∧
    (o.createdUser = some { name := i.newUserName } ↔
      ¬ ∃ u ∈ i.individualUsers, u.name = i.newUserName)

example : Spec.pre { userGroups := [{ name := "Admin" }],
                     individualUsers := [{ name := "Alice" }],
                     newGroupName := "NewGroup",
                     newUserName := "NewUser" } ∧
          Spec.post { userGroups := [{ name := "Admin" }],
                      individualUsers := [{ name := "Alice" }],
                      newGroupName := "NewGroup",
                      newUserName := "NewUser" }
                    { createdGroup := some { name := "NewGroup" },
                      createdUser := some { name := "NewUser" } } := by
  unfold Spec; decide
