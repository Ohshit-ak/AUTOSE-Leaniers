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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 8 ∧
     i.raw.toList.all (·.isDigit) = true ∧
     i.raw.splitOn ",".length = 3 ∧
     i.raw.splitOn ","[0] = "aisle" ∧
     i.raw.splitOn ","[1] = "column" ∧
     i.raw.splitOn ","[2] = "shelf")

example : Spec.pre { raw := "1,2,3" } ∧
          Spec.post { raw := "1,2,3" }
                    { valid := true } := by
  unfold Spec; decide
