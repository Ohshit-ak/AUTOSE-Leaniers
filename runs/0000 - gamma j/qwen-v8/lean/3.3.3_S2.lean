import ContractForge
open ContractForge

-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- compiles: True · rejects_bad_example: True · checked: True

structure Cart where
  items : List String
  totalCost : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List String
  totalCost : Nat
  deriving DecidableEq, Repr

structure Output where
  itemsCount : Nat
  totalCost : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.length > 0
  post := fun i o => o.itemsCount = i.items.length ∧ o.totalCost = i.totalCost

example : Spec.pre { items := ["item1", "item2"], totalCost := 150 } ∧
          Spec.post { items := ["item1", "item2"], totalCost := 150 }
                    { itemsCount := 2, totalCost := 150 } := by
  unfold Spec; decide
