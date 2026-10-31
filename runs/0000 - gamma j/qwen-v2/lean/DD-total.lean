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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 8 ∧
     i.raw.toList.all (·.isDigit ∨ · == ' ') = true ∧
     i.raw.contains "." = false ∨
     (i.raw.contains "." = true ∧
      i.raw.split ".".map String.toList.1.all (·.isDigit) = true ∧
      i.raw.split ".".map String.toList.2.all (·.isDigit ∨ · == ' ') = true))

example : Spec.pre { raw := "12.50" } ∧
          Spec.post { raw := "12.50" }
                     { valid := true, total := 1250 } := by
  unfold Spec; decide
