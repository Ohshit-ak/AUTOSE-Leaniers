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
    (i.raw ≠ "" ∧
     i.raw.length ≤ 3 ∧
     i.raw.toList.all (· ∈ ['a' to 'z', 'A' to 'Z', '0' to '9']) = true ∧
     i.raw.splitOn ",".length = 3 ∧
     i.raw.splitOn ",".map (fun x => x.trim).all (·.length = 1) = true)

example : Spec.pre { raw := "aisle1,column2,shelf3" } ∧
          Spec.post { raw := "aisle1,column2,shelf3" }
                    { valid := true } := by
  unfold Spec; decide
