-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- checked: True

structure Input where
  items : List String
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.accepted = true ∧
                     (o.message = "Order received" ∨ o.message = "Order rejected") ∧
                     i.items.Nodup

example : Spec.pre { items := ["item1", "item2"] } ∧
          Spec.post { items := ["item1", "item2"] }
                     { accepted := true, message := "Order received" } := by
  unfold Spec; decide
