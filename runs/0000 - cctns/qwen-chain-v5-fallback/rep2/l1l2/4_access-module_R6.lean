import ContractForge
open ContractForge

-- 4/access-module/R6: The System must allow changes to security attributes for groups or users (such as access rights, security level, privileges, password allocation and management) to be made only by super-user.

-- L0 spec

structure SecurityAttribute where
  user : String
  privilege : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  user : String
  privilege : String
  password : String
  isSuperUser : Bool
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isSuperUser
  post := fun i o => o.success ↔
    (i.isSuperUser = true ∧
     (i.privilege = "change_security_attributes" ∨
      i.privilege = "super_user"))

example : Spec.pre { user := "admin", privilege := "change_security_attributes", password := "pass", isSuperUser := true } ∧
          Spec.post { user := "admin", privilege := "change_security_attributes", password := "pass", isSuperUser := true }
                    { success := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { success := decide ((x.isSuperUser = true ∧
     (x.privilege = "change_security_attributes" ∨
      x.privilege = "super_user"))) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
