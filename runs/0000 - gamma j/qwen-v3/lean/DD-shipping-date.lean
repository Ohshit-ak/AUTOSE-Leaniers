-- DD-shipping-date: Date when the specified order is shipped; format MM/DD/YYYY
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
    (i.raw.length = 10 ∧
     i.raw.toList.all (·.isDigit) = true ∧
     i.raw.substring 0 2.all (·.isDigit) ∧
     i.raw.substring 3 5.all (·.isDigit) ∧
     i.raw.substring 6 8.all (·.isDigit))

example : Spec.pre { raw := "12/34/5678" } ∧
          Spec.post { raw := "12/34/5678" }
                    { valid := true } := by
  unfold Spec
  -- 12 is a valid month
  -- 34 is a valid day
  -- 56 is a valid year
  decide
