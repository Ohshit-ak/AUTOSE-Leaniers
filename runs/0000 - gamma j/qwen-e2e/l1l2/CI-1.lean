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

-- L1 architect (success=False)

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

-- Component 1: Validate Input
def ValidateInputContract : Contract Input Input where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
  post := fun i i' => i = i'

-- Component 2: Send Email
def SendEmailContract : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
  post := fun i o => o.sentEmail = true

-- Prove PO1: Each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible ValidateInputContract Spec := by
  unfold Contract.Compatible; unfold Spec; unfold ValidateInputContract; simp; discharge_po

example : Contract.Compatible SendEmailContract ValidateInputContract := by
  unfold Contract.Compatible; unfold SendEmailContract; unfold ValidateInputContract; simp; discharge_po

-- Prove PO2: The composition refines the spec
example : Contract.Refines (ValidateInputContract.seq SendEmailContract) Spec := by
  unfold Contract.Refines; unfold ValidateInputContract; unfold SendEmailContract; unfold Spec; simp; discharge_po