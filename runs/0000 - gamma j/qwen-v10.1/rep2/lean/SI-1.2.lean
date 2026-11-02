import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: False · rejects_bad_example: None · checked: False

structure Item where
  name   : String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List Item
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => o.success = true ↔
    (∀ it ∈ i.items, 0 < it.quantity) ∧
    (o.message = "Order successfully transmitted." ↔
      (∀ it ∈ i.items, 0 < it.quantity) ∧
      ∃ inv ∈ Inventory, inv.updateQuantity it.name it.quantity)

example : Spec.pre { items := [{ name := "book", quantity := 5 },
                               { name := "pen", quantity := 10 }] } ∧
          Spec.post { items := [{ name := "book", quantity := 5 },
                                { name := "pen", quantity := 10 }] }
                    { success := true, message := "Order successfully transmitted." } := by
  unfold Spec; decide
