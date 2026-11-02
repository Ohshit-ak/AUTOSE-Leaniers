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
     i.raw.toList.nth? 0 = some ' ' ∧
     i.raw.toList.nth? 1 = some ',' ∧
     i.raw.toList.nth? 2 = some ' ' ∧
     (i.raw.toList.drop 3).all (· ≠ ' ') = true)

example : Spec.pre { raw := "A 1, 2" } ∧
          Spec.post { raw := "A 1, 2" }
                    { valid := true } := by
  unfold Spec; decide
