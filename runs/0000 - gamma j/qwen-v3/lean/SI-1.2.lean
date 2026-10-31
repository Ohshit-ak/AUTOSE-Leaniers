-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- checked: True

structure Input where
  itemsOrdered : List String
  deriving DecidableEq, Repr

structure Output where
  itemsReceived : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.itemsOrdered.Nodup
  post := fun i o => o.itemsReceived = i.itemsOrdered

example : Spec.pre { itemsOrdered := ["Laptop", "Mouse"] } ∧
          Spec.post { itemsOrdered := ["Laptop", "Mouse"] }
                     { itemsReceived := ["Laptop", "Mouse"] } := by
  unfold Spec; decide
