import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.

-- L0 spec

structure Input where
  itemsOrdered : List String
  deriving DecidableEq, Repr

structure Output where
  itemsReceived : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.itemsOrdered.Nodup
  post := fun i o => o.itemsReceived = i.itemsOrdered

example : Spec.pre { itemsOrdered := ["book", "pen"] } ∧
          Spec.post { itemsOrdered := ["book", "pen"] }
                    { itemsReceived := ["book", "pen"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { itemsReceived := x.itemsOrdered }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
