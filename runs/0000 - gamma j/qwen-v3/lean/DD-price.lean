-- DD-price: Cost of a single unit of the selected item; in dollars and cents.
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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 8 ∧
     i.raw.toList.all (·.isDigit) = true ∧
     i.raw.length % 2 = 0)

example : Spec.pre { raw := "1234" } ∧
          Spec.post { raw := "1234" } { valid := true } := by
  unfold Spec; decide
