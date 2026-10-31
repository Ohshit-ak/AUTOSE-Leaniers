import ContractForge
open ContractForge

-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  customerEmail : String
  shippingAddress : String
  items : List String
  trackingNumber : String
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.shippingAddress ≠ "" ∧ i.items.Nodup ∧ i.trackingNumber ≠ ""
  post := fun i o => o.sentEmail = true ↔
    (i.customerEmail ≠ "" ∧ i.shippingAddress ≠ "" ∧ i.items.Nodup ∧ i.trackingNumber ≠ "")

example : Spec.pre { customerEmail := "customer@example.com", shippingAddress := "123 Main St", items := ["Item1", "Item2"], trackingNumber := "1234567890" } ∧
          Spec.post { customerEmail := "customer@example.com", shippingAddress := "123 Main St", items := ["Item1", "Item2"], trackingNumber := "1234567890" }
                    { sentEmail := true } := by
  unfold Spec; decide
