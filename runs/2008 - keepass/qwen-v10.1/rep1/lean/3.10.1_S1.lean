import ContractForge
open ContractForge

-- 3.10.1/S1: The user can add a new entry on the database by clicking add entry on the main menu.
-- compiles: True · rejects_bad_example: True · checked: True

structure Entry where
  description : String
  deriving DecidableEq, Repr

structure Input where
  description : String
  deriving DecidableEq, Repr

structure Output where
  added : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.description ≠ ""
  post := fun i o => o.added = true ↔ i.description ≠ ""

example : Spec.pre { description := "New entry description" } ∧
          Spec.post { description := "New entry description" }
                    { added := true } := by
  unfold Spec; decide
