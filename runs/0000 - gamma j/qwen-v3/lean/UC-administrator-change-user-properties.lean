-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- checked: True

structure Input where
  username : String
  newPassword : String
  newPrivileges : Nat
  deriving DecidableEq, Repr

structure Output where
  username : String
  accepted : Bool
  newPassword : String
  newPrivileges : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newPassword.length ≤ 20 ∧ i.newPrivileges ≤ 10
  post := fun i o => o.accepted = true ∧
                     o.username = i.username ∧
                     o.newPassword = i.newPassword ∧
                     o.newPrivileges = i.newPrivileges

example : Spec.pre { username := "admin", newPassword := "securepass", newPrivileges := 5 } ∧
          Spec.post { username := "admin", newPassword := "securepass", newPrivileges := 5 }
                     { accepted := true, username := "admin", newPassword := "securepass", newPrivileges := 5 } := by
  unfold Spec; decide
