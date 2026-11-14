import ContractForge
open ContractForge

-- 3.13.1/S1: The user can delete an existing entry by selecting it and then by clicking delete entry.
-- compiles: True · rejects_bad_example: None · checked: True

structure Entry where
  id    : Nat
  title : String
  content : String
  deriving DecidableEq, Repr

structure Input where
  entries : List Entry
  selected : Option Entry
  deriving DecidableEq, Repr

structure Output where
  entries : List Entry
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selected.isSome
  post := fun i o => o.deleted = true ↔
    ∃ e ∈ i.entries, i.selected.getD e = e ∧
    o.entries = i.entries.filter (fun e' => e' ≠ e)

example : Spec.pre { entries := [{ id := 1, title := "entry1", content := "content1" }],
                     selected := some { id := 1, title := "entry1", content := "content1" } } ∧
          Spec.post { entries := [{ id := 1, title := "entry1", content := "content1" }],
                      selected := some { id := 1, title := "entry1", content := "content1" } }
                    { entries := [], deleted := true } := by
  unfold Spec; decide
