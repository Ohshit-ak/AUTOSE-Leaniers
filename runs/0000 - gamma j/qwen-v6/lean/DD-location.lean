import ContractForge
open ContractForge

-- DD-location: Place where the item is kept in the warehouse in the form of (aisle, column, shelf)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 3 ∧
     i.raw.toList.all (fun c => c = ' ' ∨ c.isDigit) = true ∧
     i.raw.toList.nth? 0 ≠ none ∧
     i.raw.toList.nth? 1 ≠ none ∧
     i.raw.toList.nth? 2 ≠ none ∧
     (i.raw.toList.nth? 0).get.isDigit = true ∧
     (i.raw.toList.nth? 1).get.isDigit = true ∧
     (i.raw.toList.nth? 2).get.isDigit = true)

example : Spec.pre { raw := "1 2 3" } ∧
          Spec.post { raw := "1 2 3" }
                    { valid := true } := by
  unfold Spec; decide
