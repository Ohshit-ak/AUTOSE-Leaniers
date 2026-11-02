import ContractForge
open ContractForge

-- DD-shipping-date: Date when the specified order is shipped; format MM/DD/YYYY
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
    (i.raw.length = 10 ∧
     i.raw.toList.drop 0 (.take 2).all Char.isDigit = true ∧
     i.raw.toList.drop 2 (.take 1).all (· == '/') = true ∧
     i.raw.toList.drop 3 (.take 2).all Char.isDigit = true ∧
     i.raw.toList.drop 5 (.take 1).all (· == '/') = true ∧
     i.raw.toList.drop 6 (.take 2).all Char.isDigit = true)

example : Spec.pre { raw := "12/34/56" } ∧
          Spec.post { raw := "12/34/56" } { valid := true } := by
  unfold Spec; decide
