import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.

-- L0 spec

structure Order where
  items    : List String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  currentOrder : Order
  revisedOrder : Option Order
  deriving DecidableEq, Repr

structure Output where
  currentOrder : Order
  revisedOrder : Option Order
  confirmed    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.revisedOrder.isSome
  post := fun i o => (o.confirmed = true ↔
    (o.currentOrder = i.currentOrder ∧ o.revisedOrder = i.revisedOrder) ∨
    (o.currentOrder = i.revisedOrder.getD i.currentOrder ∧ o.revisedOrder = none)) ∧
    (o.revisedOrder = i.revisedOrder → o.confirmed = false)

example : Spec.pre { currentOrder := { items := ["item1"], quantity := 3 }, revisedOrder := some { items := ["item2"], quantity := 5 } } ∧
          Spec.post { currentOrder := { items := ["item1"], quantity := 3 }, revisedOrder := some { items := ["item2"], quantity := 5 } }
                    { currentOrder := { items := ["item2"], quantity := 5 }, revisedOrder := some { items := ["item2"], quantity := 5 }, confirmed := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { currentOrder := x.currentOrder,
    revisedOrder := x.revisedOrder,
    confirmed := (x.revisedOrder).isSome ∧
                (x.revisedOrder = some x.currentOrder ∨
                 x.revisedOrder = some (x.revisedOrder.getD x.currentOrder)) ∨
                (x.revisedOrder = none ∧ x.revisedOrder = none) }
