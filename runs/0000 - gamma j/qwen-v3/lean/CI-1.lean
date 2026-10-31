-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- checked: False

structure Input where
  customerName : String
  orderItems   : List String
  shippingAddress : String
  trackingNumber : String
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerName.length ≠ 0 ∧ i.orderItems.Nodup ∧ i.shippingAddress.length ≠ 0 ∧ i.trackingNumber.length ≠ 0
  post := fun i o => o.sentEmail = true ∧
                     i.customerName = "Customer Name" ∧
                     i.orderItems = ["Item 1", "Item 2"] ∧
                     i.shippingAddress = "123 Shipping St, City, State, ZIP" ∧
                     i.trackingNumber = "1234567890ABC"

example : Spec.pre { customerName := "John Doe", orderItems := ["Item 1", "Item 2"], shippingAddress := "123 Shipping St, City, State, ZIP", trackingNumber := "1234567890ABC" } ∧
          Spec.post { customerName := "John Doe", orderItems := ["Item 1", "Item 2"], shippingAddress := "123 Shipping St, City, State, ZIP", trackingNumber := "1234567890ABC" }
                    { sentEmail := true } := by
  unfold Spec; decide
