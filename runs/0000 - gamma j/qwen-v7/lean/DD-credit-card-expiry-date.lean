import ContractForge
open ContractForge

-- DD-credit-card-expiry-date: The date on the credit card when it will get expired; format MM/YY
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
    (i.raw.length = 5 ∧
     i.raw.toList.all (fun c => c.isDigit) = true ∧
     (i.raw.substring 0 2).all Char.isDigit = true ∧
     (i.raw.substring 3 2).all Char.isDigit = true)

example : Spec.pre { raw := "12/23" } ∧
          Spec.post { raw := "12/23" }
                    { valid := true } := by
  unfold Spec; decide
