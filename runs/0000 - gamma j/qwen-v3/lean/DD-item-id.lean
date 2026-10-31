-- DD-item-id: ID that uniquely identified the selected item; a 7-digit system generated alphanumeric character
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
    (i.raw.length = 7) ∧
    (i.raw.toList.all (·.isAlphanum) = true) ∧
    (i.raw.toList.any (·.isUpper) = true) ∧
    (i.raw.toList.any (·.isLower) = true)

example : Spec.pre { raw := "A1b2C3" } ∧
          Spec.post { raw := "A1b2C3" } { valid := true } := by
  unfold Spec; decide
