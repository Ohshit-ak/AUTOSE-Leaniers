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

-- L1 architect (success=False)

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

-- Component 1: Update Password
def UpdatePasswordContract : Contract Input User where
  pre  := fun i => i.username ≠ ""
  post := fun i u => u.username = i.username ∧
                     u.password = i.newPassword ∧
                     u.privileges = i.privileges

-- Component 2: Update Privileges
def UpdatePrivilegesContract : Contract User Output where
  pre  := fun u => u.username ≠ ""
  post := fun u o => o.username = u.username ∧
                     o.password = u.password ∧
                     o.privileges = u.newPrivileges

-- Prove PO1: UpdatePasswordContract's assumption follows from Spec's guarantee
example : Contract.Compatible (Spec.post) UpdatePasswordContract.pre := by
  intros i u hu
  simp [hu]
  exact (Spec.pre i)

-- Prove PO2: Composition refines the spec
example : Contract.Refines (Spec.post.seq UpdatePasswordContract.post) Spec.pre := by
  intros i o u hu
  simp [hu]
  exact (Spec.pre i)

-- Prove PO1: UpdatePrivilegesContract's assumption follows from UpdatePasswordContract's guarantee
example : Contract.Compatible UpdatePasswordContract.post UpdatePrivilegesContract.pre := by
  intros u o hu
  simp [hu]
  exact (UpdatePasswordContract.post u o)

-- Prove PO2: Composition refines the spec
example : Contract.Refines (UpdatePasswordContract.post.seq UpdatePrivilegesContract.post) Spec.post := by
  intros i o u hu ho
  simp [hu, ho]
  exact (Spec.post i o)