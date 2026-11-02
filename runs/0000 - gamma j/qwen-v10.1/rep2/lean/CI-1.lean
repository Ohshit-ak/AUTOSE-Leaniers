import ContractForge
open ContractForge

-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  customerEmail : String
  items         : List String
  shippingAddr  : String
  trackingNum   : String
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  emailBody : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
  post := fun i o => (o.sentEmail = true ↔
    i.items.length > 0 ∧
    i.customerEmail = "customer@example.com" ∧
    o.emailBody = "Your order has been confirmed. Your items will be delivered to " ++ i.shippingAddr ++ " with tracking number " ++ i.trackingNum ++ ".") ∧
    (o.sentEmail = false ↔
    i.items.length = 0 ∨
    i.customerEmail ≠ "customer@example.com" ∨
    o.emailBody ≠ "Your order has been confirmed. Your items will be delivered to " ++ i.shippingAddr ++ " with tracking number " ++ i.trackingNum ++ ".")

example : Spec.pre { customerEmail := "customer@example.com", items := ["Item1", "Item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" } ∧
          Spec.post { customerEmail := "customer@example.com", items := ["Item1", "Item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" }
                    { sentEmail := true, emailBody := "Your order has been confirmed. Your items will be delivered to 123 Main St with tracking number 1234567890." } := by
  unfold Spec; decide

example : Spec.pre { customerEmail := "customer@example.com", items := ["Item1", "Item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" } ∧
          Spec.post { customerEmail := "customer@example.com", items := ["Item1", "Item2"], shippingAddr := "123 Main St", trackingNum := "1234567890" }
                    { sentEmail := false, emailBody := "Different email content" } := by
  unfold Spec; decide
