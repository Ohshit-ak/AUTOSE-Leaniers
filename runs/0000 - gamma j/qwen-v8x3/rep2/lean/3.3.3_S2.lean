import ContractForge
open ContractForge

-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- compiles: True · rejects_bad_example: True · checked: True

structure Cart where
  items : List String
  totalCost : Nat
  itemCount : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List String
  totalCost : Nat
  itemCount : Nat
  deriving DecidableEq, Repr

structure Output where
  items : List String
  totalCost : Nat
  itemCount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.itemCount = i.items.length
  post := fun i o => o.items = i.items ∧
                     o.totalCost = i.totalCost ∧
                     o.itemCount = i.itemCount

example : Spec.pre { items := ["item1", "item2"], totalCost := 15, itemCount := 2 } ∧
          Spec.post { items := ["item1", "item2"], totalCost := 15, itemCount := 2 }
                    { items := ["item1", "item2"], totalCost := 15, itemCount := 2 } := by
  unfold Spec; decide
