import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.

-- L0 spec

structure Input where
  orderItems : List String
  customerName : String
  deriving DecidableEq, Repr

structure Output where
  orderItems : List String
  customerName : String
  revised : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderItems.length > 0
  post := fun i o => o.revised = true ↔
    (∃ item ∈ i.orderItems, item ≠ "correctedItem") ∧
    o.orderItems.length = i.orderItems.length ∧
    o.customerName = i.customerName

example : Spec.pre { orderItems := ["item1", "item2"], customerName := "John Doe" } ∧
          Spec.post { orderItems := ["item1", "item2"], customerName := "John Doe" }
                    { revised := true, orderItems := ["item1", "item2"], customerName := "John Doe" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { orderItems := x.orderItems, customerName := x.customerName, revised := decide (∃ item ∈ x.orderItems, item ≠ "correctedItem") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
