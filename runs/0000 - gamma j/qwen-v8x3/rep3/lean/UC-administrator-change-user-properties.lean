import ContractForge
open ContractForge

-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- compiles: True · rejects_bad_example: None · checked: False

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
  altered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.targetUsername ≠ "" ∧ i.newPassword ≠ "" ∧ 0 ≤ i.newPrivileges
  post := fun i o => o.altered = true ∧
    ∃ u ∈ i.users, u.username = i.targetUsername ∧
    (u.password = i.newPassword ∧ u.privileges = i.newPrivileges) ∧
    o.users = i.users.filter (fun u => u.username ≠ i.targetUsername) ++
              [{ username := i.targetUsername, password := i.newPassword, privileges := i.newPrivileges }] ++ 
              i.users.filter (fun u => u.username = i.targetUsername ∧ u.password ≠ i.newPassword ∧ u.privileges ≠ i.newPrivileges)

example : Spec.pre { users := [{ username := "admin", password := "pass1", privileges := 5 }],
                     targetUsername := "admin", newPassword := "pass2", newPrivileges := 6 } ∧
          Spec.post { users := [{ username := "admin", password := "pass2", privileges := 6 }],
                      targetUsername := "admin", newPassword := "pass2", newPrivileges := 6 }
                    { altered := true, users := [{ username := "admin", password := "pass2", privileges := 6 }] } := by
  unfold Spec; decide
