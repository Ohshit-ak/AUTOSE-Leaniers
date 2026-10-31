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
     i.raw.toList.all (fun c => c = ',' ∨ c.isDigit) = true ∧
     i.raw.split ',' = ["aisle", "column", "shelf"] ∧
     i.raw.split ',').map String.toList.all (fun c => c.isDigit) = [true, true, true])

example : Spec.pre { raw := "aisle,123,column,456,shelf,789" } ∧
          Spec.post { raw := "aisle,123,column,456,shelf,789" }
                    { valid := false } := by
  unfold Spec; decide
