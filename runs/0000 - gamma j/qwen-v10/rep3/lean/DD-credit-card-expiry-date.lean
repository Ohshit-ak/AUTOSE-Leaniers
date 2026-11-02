import ContractForge
open ContractForge

-- DD-credit-card-expiry-date: The date on the credit card when it will get expired; format MM/YY
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 5 ∧
     i.raw.toList.all Char.isDigit = true ∧
     (i.raw.toList.take 2).all Char.isDigit = true ∧
     ((i.raw.toList.drop 3).take 2).all Char.isDigit = true)

example : Spec.pre { raw := "12/23" } ∧ Spec.post { raw := "12/23" } { valid := false } := by
  unfold Spec; decide
