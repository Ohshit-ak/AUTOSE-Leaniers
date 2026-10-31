-- DD-quantity: the number of units of each selected item that the customer is ordering; default = 1; maximum = quantity presently in inventory
-- checked: True

structure Input where
  raw : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw ∧ i.raw ≤ 100) -- Assuming the inventory quantity is 100 for simplicity

example : Spec.pre { raw := 5 } ∧ Spec.post { raw := 5 } { valid := true } := by
  unfold Spec; decide
