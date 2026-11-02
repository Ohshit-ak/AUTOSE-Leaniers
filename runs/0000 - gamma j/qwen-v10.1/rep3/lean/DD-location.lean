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
    (i.raw.length = 3 ∧
     i.raw.toList.all (fun c => c == ',' ∨ (c.isDigit ∧ 1 ≤ c.toNat ∧ c.toNat ≤ 99)) = true)

example : Spec.pre { raw := "1,1,1" } ∧ Spec.post { raw := "1,1,1" } { valid := false } := by
  unfold Spec; decide
