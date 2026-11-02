import ContractForge
open ContractForge

-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- compiles: False · rejects_bad_example: None · checked: False

structure CartItem where
  name : String
  price : Nat
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List CartItem
  deriving DecidableEq, Repr

structure Output where
  itemCount : Nat
  totalCost : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => o.itemCount = i.items.sum (fun x => x.quantity) ∧
                     o.totalCost = i.items.sum (fun x => x.quantity * x.price)

example : Spec.pre { items := [{ name := "item1", price := 10, quantity := 2 },
                                { name := "item2", price := 20, quantity := 1 }] } ∧
          Spec.post { items := [{ name := "item1", price := 10, quantity := 2 },
                                 { name := "item2", price := 20, quantity := 1 }] }
                    { itemCount := 3, totalCost := 40 } := by
  unfold Spec; decide
