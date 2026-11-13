import ContractForge
open ContractForge

-- Design Constraints/I1#9: The system admin only can able to create User Groups

-- L0 spec

structure UserGroup where
  name : String
  deriving DecidableEq, Repr

structure User where
  name : String
  groups : List UserGroup
  deriving DecidableEq, Repr

structure Admin where
  name : String
  groups : List UserGroup
  deriving DecidableEq, Repr

structure Input where
  admin : Admin
  name  : String
  groups : List UserGroup
  deriving DecidableEq, Repr

structure Output where
  created : Bool
  groups  : List UserGroup
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.admin.groups = [] -- The admin has no user groups
  post := fun i o => o.created = true ↔
    i.admin.name ≠ "" ∧
    i.name ≠ "" ∧
    i.groups = [] ∧
    o.groups = i.groups

example : Spec.pre { admin := { name := "admin", groups := [] },
                     name := "group1", groups := [] } ∧
          Spec.post { admin := { name := "admin", groups := [] },
                      name := "group1", groups := [] }
                    { created := true, groups := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { created := x.admin.name ≠ "" ∧ x.name ≠ "" ∧ x.groups = [],
    groups := x.groups }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
