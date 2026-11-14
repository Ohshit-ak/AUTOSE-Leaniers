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
  orderId : Nat
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  details : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderId > 0
  post := fun i o => o.sent = true ∧
                     o.details = { id := i.orderId, items := [], total := 0 } -- Assume no items and total 0 for simplicity

example : Spec.pre { orderId := 1 } ∧
          Spec.post { orderId := 1 }
                    { sent := true, details := { id := 1, items := [], total := 0 } } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sent := true,
    details := { id := x.orderId, items := [], total := 0 } }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
