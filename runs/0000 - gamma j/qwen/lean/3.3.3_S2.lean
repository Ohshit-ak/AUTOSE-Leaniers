-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- checked: True

structure Input where
  itemCount : Nat
  totalCost  : Nat
  deriving DecidableEq, Repr

structure Output where
  itemCount : Nat
  totalCost  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.itemCount ≥ 0 ∧ i.totalCost ≥ 0
  post := fun i o => o.itemCount = i.itemCount ∧ o.totalCost = i.totalCost

example : Spec.pre { itemCount := 3, totalCost := 1500 } ∧
          Spec.post { itemCount := 3, totalCost := 1500 } { itemCount := 3, totalCost := 1500 } := by
  unfold Spec; decide
