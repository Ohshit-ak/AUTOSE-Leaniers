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
