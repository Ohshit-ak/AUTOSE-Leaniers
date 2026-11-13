import ContractForge
open ContractForge

-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.

-- L0 spec

structure Input where
  customerEmail : String
  items         : List String
  shippingAddr  : String
  trackingNum   : String
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
  post := fun i o => o.sentEmail = true ↔
    (i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ "")

example : Spec.pre { customerEmail := "customer@example.com", items := ["item1", "item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" } ∧
          Spec.post { customerEmail := "customer@example.com", items := ["item1", "item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" }
                    { sentEmail := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sentEmail := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
