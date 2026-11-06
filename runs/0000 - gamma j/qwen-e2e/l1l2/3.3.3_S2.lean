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

-- L1 architect (success=False)

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

-- Decompose the spec into two components

def CountItemsContract : Contract (Input, Nat) Output where
  pre  := fun (i, itemCount) => i.items.Nodup ∧
           itemCount = (i.items.map (fun x => x.quantity)).sum
  post := fun (i, _) o => o.itemCount = itemCount ∧
                           o.totalCost = (i.items.map (fun x => x.quantity * x.price)).sum

def CalculateTotalCostContract : Contract (Input, Output) Output where
  pre  := fun (i, o) => o.itemCount = (i.items.map (fun x => x.quantity)).sum
  post := fun (i, o) o' => o' = o

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_CountItems : Contract.Compatible CountItemsContract Spec :=
  by
    unfold CountItemsContract Spec
    intros i itemCount o
    simp [CountItemsContract.pre, Spec.pre]
    exact Nat.eq_of_add_right_eq_add_right

theorem PO1_CalculateTotalCost : Contract.Compatible CalculateTotalCostContract CountItemsContract :=
  by
    unfold CalculateTotalCostContract CountItemsContract
    intros i o o'
    simp [CalculateTotalCostContract.pre, CountItemsContract.post]
    exact Nat.eq_of_add_right_eq_add_right

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (CountItemsContract.seq CalculateTotalCostContract) Spec :=
  by
    unfold CountItemsContract CalculateTotalCostContract Spec
    intros i o
    simp [CountItemsContract.post, CalculateTotalCostContract.post]
    exact Nat.eq_of_add_right_eq_add_right

-- Discharge PO1 and PO2
discharge_po