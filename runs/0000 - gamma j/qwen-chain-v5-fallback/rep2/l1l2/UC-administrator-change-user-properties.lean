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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { username := x.username,
    password := x.newPassword,
    privileges := x.newPrivileges }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
