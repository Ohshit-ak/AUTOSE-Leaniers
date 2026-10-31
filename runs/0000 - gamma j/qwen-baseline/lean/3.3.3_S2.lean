-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- checked: True

structure Input where
  itemCount : Nat
  totalCost  : Nat

structure Output where
  itemCountShown : Nat
  totalCostShown  : Nat

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.itemCountShown = i.itemCount ∧ o.totalCostShown = i.totalCost

example : Spec.pre ⟨10, 200⟩ ∧ Spec.post ⟨10, 200⟩ ⟨10, 200⟩ := by
  simp [Spec]
