-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- checked: None

structure Contract (Input Output : Type) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure Item where
  name : String
  quantity : Nat

structure Order where
  items : List Item

structure Inventory where
  items : List Item

def Spec : Contract Order Inventory where
  pre order := true
  post order inventory := inventory.items.Perm (order.items.map (fun i => i.name, i.quantity))

example : Spec (Order.mk [(Item.mk "Apple" 5), (Item.mk "Banana" 3)]) (Inventory.mk [(Item.mk "Apple" 5), (Item.mk "Banana" 3)]) := by
  simp [Spec.post]
