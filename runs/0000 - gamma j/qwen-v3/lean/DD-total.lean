-- DD-total: Cost of a single unit of the selected item Number of units of that item selected; in dollars and cents
-- checked: False

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  total : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 4 ∧
     i.raw.toList.all (·.isDigit) = true ∧
     o.total = i.raw.natValue * 100)

example : Spec.pre { raw := "1234" } ∧
          Spec.post { raw := "1234" } { valid := true, total := 123400 } := by
  unfold Spec; decide
