-- DD-price: Cost of a single unit of the selected item; in dollars and cents.
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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 10) ∧
    i.raw.toList.any (· = '.') = true ∧
    i.raw.toList.all (·.isDigit) = true

example : Spec.pre { raw := "123.45" } ∧
          Spec.post { raw := "123.45" } { valid := true } := by
  unfold Spec
  simp
  decide
