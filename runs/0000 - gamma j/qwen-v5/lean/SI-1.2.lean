-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- checked: True

structure Input where
  itemIds : List Nat
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.itemIds.Nodup
  post := fun i o => o.received = true ∧
                     (i.itemIds.all (fun id => id > 0) = true)

example : Spec.pre { itemIds := [1, 2, 3] } ∧
          Spec.post { itemIds := [1, 2, 3] } { received := true } := by
  unfold Spec; decide
