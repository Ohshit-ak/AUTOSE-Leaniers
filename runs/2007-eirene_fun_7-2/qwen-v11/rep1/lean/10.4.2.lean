import ContractForge
open ContractForge

-- 10.4.2: 10.4.2 Activating a group on the mobile shall allow a user to receive a call from that group. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Group where
  name : String
  deriving DecidableEq, Repr

structure User where
  groups : List Group
  deriving DecidableEq, Repr

structure Input where
  group : Group
  user  : User
  deriving DecidableEq, Repr

structure Output where
  user  : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user.groups.contains i.group
  post := fun i o => o.user.groups = i.user.groups ∧
                     (o.user.groups.contains i.group ↔
                      i.user.groups.contains i.group)

example : Spec.pre { group := { name := "Tech" }, user := { groups := [{ name := "Tech" }] } } ∧
          Spec.post { group := { name := "Tech" }, user := { groups := [{ name := "Tech" }] } }
                    { user := { groups := [{ name := "Tech" }] } } := by
  unfold Spec; decide
