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
     i.raw.toList.all (fun c => c.isDigit ∨ (c = '/' ∧ c.isAlpha)) = true ∧
     i.raw.toList.getD 0 "default".toList.all (·.isDigit) = true ∧
     i.raw.toList.getD 1 "default".toList.all (·.isDigit) = true ∧
     i.raw.toList.getD 3 "default".toList.all (·.isDigit) = true ∧
     i.raw.toList.getD 4 "default".toList.all (·.isDigit) = true ∧
     i.raw.toList.getD 6 "default".toList.all (·.isDigit) = true ∧
     i.raw.toList.getD 7 "default".toList.all (·.isDigit) = true)

example : Spec.pre { raw := "12/34/5678" } ∧
          Spec.post { raw := "12/34/5678" } { valid := true } := by
  unfold Spec; decide
