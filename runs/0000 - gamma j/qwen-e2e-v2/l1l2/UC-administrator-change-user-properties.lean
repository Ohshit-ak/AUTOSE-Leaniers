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

structure Mid where
  username : String
  password : String
  deriving DecidableEq, Repr

def UpdatePasswordContract : Contract Input Mid where
  pre  := fun i => i.username ≠ ""
  post := fun i m => m.username = i.username ∧ m.password = i.newPassword

def UpdatePrivilegesContract : Contract Mid Output where
  pre  := fun m => m.username ≠ "" ∧ m.password ≠ ""
  post := fun m o => o.username = m.username ∧
                     o.password = m.password ∧
                     o.privileges = m.newPrivileges

theorem po1 : Contract.Compatible UpdatePasswordContract UpdatePrivilegesContract := by
  unfold Contract.Compatible UpdatePasswordContract UpdatePrivilegesContract
  intro i m _ h
  exact h.2.2

theorem po2 : Contract.Refines (UpdatePasswordContract.seq UpdatePrivilegesContract) Spec := by
  unfold Contract.Refines Contract.seq UpdatePasswordContract UpdatePrivilegesContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]