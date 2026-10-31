-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- checked: False

structure Input where
  customerName : String
  deliveryAddress : String
  items : List String
  trackingNumber : String
  deriving DecidableEq, Repr

structure Output where
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerName.length > 0 ∧
                   i.deliveryAddress.length > 0 ∧
                   i.items.Nodup ∧
                   i.trackingNumber.length = 10
  post := fun i o => o.emailSent = true ∧
                     i.customerName = o.customerName ∧
                     i.deliveryAddress = o.deliveryAddress ∧
                     i.items = o.items ∧
                     i.trackingNumber = o.trackingNumber

example : Spec.pre { customerName := "John Doe", deliveryAddress := "123 Elm St, Anytown, AN 12345", items := ["Laptop", "Mouse"], trackingNumber := "a1a1a1a1a1" } ∧
          Spec.post { customerName := "John Doe", deliveryAddress := "123 Elm St, Anytown, AN 12345", items := ["Laptop", "Mouse"], trackingNumber := "a1a1a1a1a1" } { emailSent := true, customerName := "John Doe", deliveryAddress := "123 Elm St, Anytown, AN 12345", items := ["Laptop", "Mouse"], trackingNumber := "a1a1a1a1a1" } := by
  unfold Spec; decide
