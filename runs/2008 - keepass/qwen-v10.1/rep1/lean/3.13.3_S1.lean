import ContractForge
open ContractForge

-- 3.13.3/S1: REQ-17: An entry must be selected to be deleted
-- compiles: True · rejects_bad_example: None · checked: False

structure Entry where
  id   : Nat
  data : String
  deriving DecidableEq, Repr

structure Input where
  entries   : List Entry
  selectedId: Nat
  deriving DecidableEq, Repr

structure Output where
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selectedId ≠ 0 ∧ ∃ e ∈ i.entries, e.id = i.selectedId
  post := fun i o => o.deleted = true ↔ ∃ e ∈ i.entries, e.id = i.selectedId

example : Spec.pre { entries := [{ id := 1, data := "entry1" }, { id := 2, data := "entry2" }],
                     selectedId := 2 } ∧
          Spec.post { entries := [{ id := 1, data := "entry1" }, { id := 2, data := "entry2" }],
                      selectedId := 2 }
                    { deleted := true } := by
  unfold Spec; decide
