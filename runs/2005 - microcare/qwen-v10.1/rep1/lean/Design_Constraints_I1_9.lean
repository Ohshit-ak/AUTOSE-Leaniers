import ContractForge
open ContractForge

-- Design Constraints/I1#9: The system admin only can able to create User Groups
-- compiles: True · rejects_bad_example: True · checked: True

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
