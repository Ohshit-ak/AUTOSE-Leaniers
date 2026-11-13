import ContractForge
open ContractForge

-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.

-- L0 spec

structure User where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

structure Input where
  username : String
  newPassword : String
  newPrivileges : Nat
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.username = i.username ∧
                     o.password = i.newPassword ∧
                     o.privileges = i.newPrivileges

example : Spec.pre { username := "admin", newPassword := "newpw", newPrivileges := 5 } ∧
          Spec.post { username := "admin", newPassword := "newpw", newPrivileges := 5 }
                    { username := "admin", password := "newpw", privileges := 5 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  username : String
  newPassword : String
  newPrivileges : Nat
  deriving DecidableEq, Repr

def UpdateUserContract : Contract Input Mid where
  pre  := fun i => i.username ≠ ""
  post := fun i m => m.username = i.username ∧ m.newPassword = i.newPassword ∧ m.newPrivileges = i.newPrivileges

def ApplyChangesContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.username = m.username ∧ o.password = m.newPassword ∧ o.privileges = m.newPrivileges
