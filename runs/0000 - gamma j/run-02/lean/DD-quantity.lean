-- DD-quantity: the number of units of each selected item that the customer is ordering; default = 1; maximum = quantity presently in inventory
-- checked: True

structure Input where
  value : Nat
  max_ref : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ (1 ≤ i.value ∧ i.value ≤ i.max_ref)

example : Spec.pre { value := 5, max_ref := 10 } ∧
          Spec.post { value := 5, max_ref := 10 } { valid := true } := by
  unfold Spec; decide
