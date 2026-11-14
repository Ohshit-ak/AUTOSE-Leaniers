import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.

-- L0 spec

structure Order where
  id      : Nat
  items   : List String
  total   : Nat
  deriving DecidableEq, Repr

structure Input where
  orderDetails : Order
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  order     : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderDetails.id ≠ 0
  post := fun i o => o.sentEmail = true ∧
                     o.order.id = i.orderDetails.id ∧
                     o.order.items = i.orderDetails.items ∧
                     o.order.total = i.orderDetails.total

example : Spec.pre { orderDetails := { id := 123, items := ["item1", "item2"], total := 150 } } ∧
          Spec.post { orderDetails := { id := 123, items := ["item1", "item2"], total := 150 } }
                     { sentEmail := true, order := { id := 123, items := ["item1", "item2"], total := 150 } } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sentEmail := true,
    order := { id := x.orderDetails.id, items := x.orderDetails.items, total := x.orderDetails.total } }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
