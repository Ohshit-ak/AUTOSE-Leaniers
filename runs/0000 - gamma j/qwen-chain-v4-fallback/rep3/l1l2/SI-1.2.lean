import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { success := x.orderedItems.Nodup,
    updatedItems := x.orderedItems.map fun it =>
      { name := it.name, count := it.count + 1 } }
