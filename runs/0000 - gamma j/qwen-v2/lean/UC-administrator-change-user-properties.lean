-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- checked: True

structure Input where
  userId : Nat
  oldPassword : String
  newPassword : String
  oldPrivileges : Nat
  newPrivileges : Nat
  deriving DecidableEq, Repr

structure Output where
  userId : Nat
  passwordAltered : Bool
  privilegesAltered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.oldPassword ≠ "" ∧ i.oldPrivileges < 100
  post := fun i o => o.userId = i.userId ∧
                     (o.passwordAltered = true ↔ i.newPassword ≠ i.oldPassword) ∧
                     (o.privilegesAltered = true ↔ i.newPrivileges ≠ i.oldPrivileges)

example : Spec.pre { userId := 1, oldPassword := "oldpass", newPassword := "newpass", oldPrivileges := 10, newPrivileges := 20 } ∧
          Spec.post { userId := 1, oldPassword := "oldpass", newPassword := "newpass", oldPrivileges := 10, newPrivileges := 20 }
                    { userId := 1, passwordAltered := true, privilegesAltered := true } := by
  unfold Spec; decide
