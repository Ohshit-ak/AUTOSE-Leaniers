import ContractForge
open ContractForge

-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- compiles: True · rejects_bad_example: None · checked: True

structure Cart where
  items : List Nat
  totalCost : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List Nat
  deriving DecidableEq, Repr

structure Output where
  itemsInCart : Nat
  totalCost : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => o.itemsInCart = i.items.length ∧
                     o.totalCost = i.items.sum

example : Spec.pre { items := [3, 5] } ∧
          Spec.post { items := [3, 5] }
                    { itemsInCart := 2, totalCost := 8 } := by
  unfold Spec; decide
