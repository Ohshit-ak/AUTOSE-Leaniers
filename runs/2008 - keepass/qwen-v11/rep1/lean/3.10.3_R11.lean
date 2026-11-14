import ContractForge
open ContractForge

-- 3.10.3/R11: An entry must belong to a group to be created
-- compiles: True · rejects_bad_example: True · checked: True

structure Group where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Entry where
  id : Nat
  name : String
  groupId : Nat
  deriving DecidableEq, Repr

structure Input where
  name : String
  groupId : Nat
  deriving DecidableEq, Repr

structure Output where
  id : Nat
  name : String
  groupId : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groupId ≠ 0
  post := fun i o => o.groupId = i.groupId ∧
                     o.name = i.name ∧
                     o.id ≠ 0

example : Spec.pre { name := "New Entry", groupId := 1 } ∧
          Spec.post { name := "New Entry", groupId := 1 }
                    { id := 1, name := "New Entry", groupId := 1 } := by
  unfold Spec; decide
