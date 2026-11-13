import ContractForge
open ContractForge

-- 3.12.1/S1: The user can create an exact copy of an entry.
-- compiles: False · rejects_bad_example: None · checked: False

structure Entry where
  id   : Nat
  name : String
  deriving DecidableEq, Repr

structure Input where
  entries : List Entry
  deriving DecidableEq, Repr

structure Output where
  entries : List Entry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.entries.Nodup
  post := fun i o => o.entries.length = i.entries.length + 1 ∧
                     o.entries.last.id = i.entries.length + 1 ∧
                     o.entries.last.name = i.entries.last.name ∧
                     ∀ j ∈ o.entries, j ≠ o.entries.last →
                     ∃ e ∈ i.entries, j.id = e.id ∧ j.name = e.name

example : Spec.pre { entries := [{ id := 1, name := "entry1" }, { id := 2, name := "entry2" }] } ∧
          Spec.post { entries := [{ id := 1, name := "entry1" }, { id := 2, name := "entry2" }] }
                     { entries := [{ id := 1, name := "entry1" }, { id := 2, name := "entry2" }, { id := 3, name := "entry1" }] } := by
  unfold Spec; decide
