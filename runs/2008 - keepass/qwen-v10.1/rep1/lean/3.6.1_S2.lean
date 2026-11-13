import ContractForge
open ContractForge

-- 3.6.1/S2: The user can create a new group or subgroups into an existing group.
-- compiles: True · rejects_bad_example: None · checked: True

structure Group where
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Output where
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ ""
  post := fun i o => o.name = i.name ∧ o.parent = i.parent

example : Spec.pre { name := "New Group", parent := none } ∧
          Spec.post { name := "New Group", parent := none }
                    { name := "New Group", parent := none } := by
  unfold Spec; decide
