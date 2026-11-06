import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Item where
  name   : String
  count  : Nat
  deriving DecidableEq, Repr

structure Input where
  orderedItems : List Item
  deriving DecidableEq, Repr

structure Output where
  success  : Bool
  updatedItems : List Item
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderedItems.Nodup
  post := fun i o => (o.success = true ↔
    ∀ it ∈ i.orderedItems, ∃ uit ∈ o.updatedItems, uit.name = it.name ∧ uit.count = it.count + 1)

example : Spec.pre { orderedItems := [{ name := "Laptop", count := 3 }, { name := "Mouse", count := 2 }] } ∧ Spec.post { orderedItems := [{ name := "Laptop", count := 3 }, { name := "Mouse", count := 2 }] } { success := false, updatedItems := [{ name := "Laptop", count := 3 }, { name := "Mouse", count := 2 }] } := by
  unfold Spec; decide
