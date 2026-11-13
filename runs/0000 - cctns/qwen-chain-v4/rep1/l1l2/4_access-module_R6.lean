import ContractForge
open ContractForge

-- 4/access-module/R6: The System must allow changes to security attributes for groups or users (such as access rights, security level, privileges, password allocation and management) to be made only by super-user.

-- L0 spec

structure Input where
  superUser : Bool
  group     : String
  user      : String
  deriving DecidableEq, Repr

structure Output where
  changed  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.superUser
  post := fun i o => (o.changed = true ↔
    (i.group ≠ "" ∨ i.user ≠ ""))

example : Spec.pre { superUser := true, group := "admin", user := "" } ∧
          Spec.post { superUser := true, group := "admin", user := "" }
                    { changed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { changed := decide (x.group ≠ "" ∨ x.user ≠ "") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
