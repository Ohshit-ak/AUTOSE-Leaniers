import ContractForge
open ContractForge

-- 3.8.1/S1: When a user wants to delete an existing group/subgroup he can do this by selecting Delete group/subgroup from the edit menu.
-- compiles: False · rejects_bad_example: None · checked: False

structure Group where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Input where
  groups : List Group
  selectedId : Option Nat
  deriving DecidableEq, Repr

structure Output where
  groups : List Group
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selectedId.isSome
  post := fun i o => (o.deleted = true ↔
    ∃ g ∈ i.groups, g.id = i.selectedId.get ∧
    o.groups = i.groups.filter (fun g' => g'.id ≠ g.id))

example : Spec.pre { groups := [{ id := 1, name := "Group1" }, { id := 2, name := "Group2" }],
                     selectedId := some 2 } ∧
          Spec.post { groups := [{ id := 1, name := "Group1" }, { id := 2, name := "Group2" }],
                      selectedId := some 2 }
                    { groups := [{ id := 1, name := "Group1" }, { id := 2, name := "Group2" }],
                      deleted := true } := by
  unfold Spec; decide
