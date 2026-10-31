-- DD-shipping-price: Cost for shipping the item to its destination; in dollars and cents
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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 8 ∧
     i.raw.toList.all Char.isDigit = true ∧
     i.raw.last = '.' ∧
     i.raw.slice 0 (i.raw.length - 1).toNat.all Char.isDigit = true)

example : Spec.pre { raw := "12.34" } ∧ Spec.post { raw := "12.34" } { valid := true } := by
  unfold Spec; decide
