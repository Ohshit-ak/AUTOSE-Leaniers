-- DD-credit-card-no: Credit card number of the customer; 16 digit numeric string
-- checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 16) ∧
    (i.raw.toList.all Char.isDigit = true)

example : Spec.pre { raw := "1234567890123456" } ∧
          Spec.post { raw := "1234567890123456" }
                    { valid := true } := by
  unfold Spec; decide
