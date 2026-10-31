-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- checked: True

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
  post := fun i o => o.sentEmail = true ∧
                     (i.customerEmail = "customer@example.com" →
                      i.items = ["Item1", "Item2"] ∧
                      i.shippingAddr = "123 Main St, Anytown, AN 12345" ∧
                      i.trackingNum = "ABC1234567890")

example : Spec.pre { customerEmail := "customer@example.com", items := ["Item1", "Item2"], shippingAddr := "123 Main St, Anytown, AN 12345", trackingNum := "ABC1234567890" } ∧
          Spec.post { customerEmail := "customer@example.com", items := ["Item1", "Item2"], shippingAddr := "123 Main St, Anytown, AN 12345", trackingNum := "ABC1234567890" }
                    { sentEmail := true } := by
  unfold Spec; decide
