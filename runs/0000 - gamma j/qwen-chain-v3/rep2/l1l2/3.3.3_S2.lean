import ContractForge
open ContractForge

-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.

-- L0 spec

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

example : Spec.pre { items := [{ name := "item1", price := 10, quantity := 2 },
                                { name := "item2", price := 20, quantity := 1 }] } ∧
          Spec.post { items := [{ name := "item1", price := 10, quantity := 2 },
                                 { name := "item2", price := 20, quantity := 1 }] }
                    { itemCount := 3, totalCost := 40 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  itemCount : Nat
  items : List CartItem
  deriving DecidableEq, Repr

def CalculateItemCountContract : Contract Input Mid where
  pre  := fun i => i.items.Nodup
  post := fun i m => m.itemCount = (i.items.map (fun x => x.quantity)).sum ∧ m.items = i.items

def CalculateTotalCostContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.totalCost = (m.itemCount * (m.items.head.price)).get_or_else 0
