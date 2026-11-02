import ContractForge
open ContractForge

-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- compiles: True · rejects_bad_example: True · checked: True

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
  post := fun i o => o.itemCount = (i.items.map (fun x => x.quantity)).sum ∧
                     o.totalCost = (i.items.map (fun x => x.quantity * x.price)).sum

example : Spec.pre { items := [{ name := "book", price := 10, quantity := 2 },
                                { name := "pen", price := 5, quantity := 3 }] } ∧
          Spec.post { items := [{ name := "book", price := 10, quantity := 2 },
                                { name := "pen", price := 5, quantity := 3 }] }
                    { itemCount := 5, totalCost := 35 } := by
  unfold Spec; decide
