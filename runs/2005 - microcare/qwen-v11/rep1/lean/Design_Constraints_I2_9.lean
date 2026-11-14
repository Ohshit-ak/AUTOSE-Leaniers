import ContractForge
open ContractForge

-- Design Constraints/I2#9: The system should have the provision to create any number of individual user under any user group. Each Individual User should have the following information Group Name (Selecting from User Group) User Name Password Verify Password
-- compiles: True · rejects_bad_example: True · checked: True

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
      i.individualUser.groupName ∈ i.userGroups.map (·.name) ∧
      i.individualUser.password = i.individualUser.verifyPassword)

example : Spec.pre { userGroups := [{ name := "Admin" }, { name := "User" }],
                     individualUser := { groupName := "User", userName := "user1", password := "pass", verifyPassword := "pass" } } ∧
          Spec.post { userGroups := [{ name := "Admin" }, { name := "User" }],
                      individualUser := { groupName := "User", userName := "user1", password := "pass", verifyPassword := "pass" } }
                    { created := true } := by
  unfold Spec; decide
