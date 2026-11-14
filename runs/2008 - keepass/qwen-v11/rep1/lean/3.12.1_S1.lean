import ContractForge
open ContractForge

-- 3.12.1/S1: The user can create an exact copy of an entry.
-- compiles: False · rejects_bad_example: None · checked: False

structure Entry where
  id    : Nat
  name  : String
  value : Nat
  deriving DecidableEq, Repr

structure Input where
  entries : List Entry
  deriving DecidableEq, Repr

structure Output where
  entries : List Entry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.entries.Nodup
  post := fun i o => o.entries = i.entries ++ [i.entries.head] ∧
                     o.entries.length = i.entries.length + 1

example : Spec.pre { entries := [{ id := 1, name := "A", value := 10 }] } ∧
          Spec.post { entries := [{ id := 1, name := "A", value := 10 }] }
                    { entries := [{ id := 1, name := "A", value := 10 }, { id := 2, name := "A", value := 10 }] } := by
  unfold Spec; decide
