import ContractForge
open ContractForge

-- DD-location: Place where the item is kept in the warehouse in the form of (aisle, column, shelf)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 3 ∧
     i.raw.toList.all (fun c => c == 'a' ∨ c == 'c' ∨ c == 's') = true)

example : Spec.pre { raw := "a1c" } ∧ Spec.post { raw := "a1c" } { valid := false } := by
  unfold Spec; decide
