import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Item where
  id     : Nat
  name   : String
  price  : Nat
  deriving DecidableEq, Repr

structure Input where
  orderItems : List Item
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderItems.Nodup
  post := fun i o => o.accepted ↔ i.orderItems.length > 0 ∧
                     (∀ x ∈ i.orderItems, 0 < x.price) ∧
                     o.message = if o.accepted then "Order accepted" else "Order rejected"

example : Spec.pre { orderItems := [{ id := 1, name := "Item1", price := 100 }] } ∧
          Spec.post { orderItems := [{ id := 1, name := "Item1", price := 100 }] }
                    { accepted := true, message := "Order accepted" } := by
  unfold Spec; decide
