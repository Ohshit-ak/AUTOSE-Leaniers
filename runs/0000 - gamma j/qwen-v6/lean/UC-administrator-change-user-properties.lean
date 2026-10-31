import ContractForge
open ContractForge

-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- compiles: False · rejects_bad_example: None · checked: False

structure User where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

structure Input where
  users : List User
  targetUsername : String
  newPassword : String
  newPrivileges : Nat
  deriving DecidableEq, Repr

structure Output where
  users : List User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.targetUsername ≠ "" ∧
                   ∃ u ∈ i.users, u.username = i.targetUsername
  post := fun i o => o.users = i.users.map (fun u => 
    if u.username = i.targetUsername then
      { username := u.username, password := i.newPassword, privileges := i.newPrivileges }
    else
      u
  ) ∧
    o.users.nodup ∧
    ∃ u ∈ o.users, u.username = i.targetUsername ∧ u.password = i.newPassword ∧ u.privileges = i.newPrivileges

example : Spec.pre { users := [{ username := "john", password := "pass1", privileges := 2 }],
                     targetUsername := "john", newPassword := "newpass", newPrivileges := 3 } ∧
          Spec.post { users := [{ username := "john", password := "newpass", privileges := 3 }],
                      targetUsername := "john", newPassword := "newpass", newPrivileges := 3 }
                    { users := [{ username := "john", password := "newpass", privileges := 3 }] } := by
  unfold Spec; decide
