-- DD-location: Place where the item is kept in the warehouse in the form of (aisle, column, shelf)
-- checked: False

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
     i.raw.toList.all (fun c => c.isAlphanum) = true ∧
     i.raw.toList.map (fun c => c) = ["(", "aisle", ",", "column", ",", "shelf", ")"])

example : Spec.pre { raw := "(aisle,column,shelf)" } ∧
          Spec.post { raw := "(aisle,column,shelf)" } { valid := true } := by
  unfold Spec; decide
