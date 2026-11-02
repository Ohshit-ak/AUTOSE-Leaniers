import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Item where
  name   : String
  price  : Nat
  stock  : Nat
  deriving DecidableEq, Repr

structure OrderItem where
  item   : Item
  amount : Nat
  deriving DecidableEq, Repr

structure Input where
  orderItems : List OrderItem
  deriving DecidableEq, Repr

structure Output where
  updatedStock : List Item
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderItems.length > 0
  post := fun i o =>
    o.updatedStock.length = i.orderItems.length ∧
    ∀ j ∈ i.orderItems, o.updatedStock.count j.item = j.amount ∧
    (∀ j ∈ i.orderItems, 0 ≤ j.amount ∧ j.amount ≤ j.item.stock) →
    o.updatedStock.Nodup ∧
    List.Pairwise (fun a b => a.stock ≤ b.stock) o.updatedStock

example : Spec.pre { orderItems := [{ item := { name := "Laptop", price := 1000, stock := 50 },
                                      amount := 2 },
                                    { item := { name := "Mouse", price := 50, stock := 100 },
                                      amount := 5 }] } ∧
          Spec.post { orderItems := [{ item := { name := "Laptop", price := 1000, stock := 50 },
                                       amount := 2 },
                                     { item := { name := "Mouse", price := 50, stock := 100 },
                                       amount := 5 }] }
                    { updatedStock := [{ name := "Laptop", price := 1000, stock := 48 },
                                       { name := "Mouse", price := 50, stock := 95 }] } := by
  unfold Spec; decide
