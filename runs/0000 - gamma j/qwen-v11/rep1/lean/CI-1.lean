import ContractForge
open ContractForge

-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  customerEmail : String
  deliveryAddress : String
  items : List String
  trackingNumber : String
  deriving DecidableEq, Repr

structure Output where
  emailSent : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.deliveryAddress ≠ "" ∧ i.items.Nodup ∧ i.trackingNumber ≠ ""
  post := fun i o => o.emailSent = true ∧
                     o.message = "Your order has been confirmed. Your items will be delivered to " ++ i.deliveryAddress ++ " with tracking number " ++ i.trackingNumber

example : Spec.pre { customerEmail := "customer@example.com", deliveryAddress := "123 Elm St",
                     items := ["item1", "item2"], trackingNumber := "1234567890" } ∧
          Spec.post { customerEmail := "customer@example.com", deliveryAddress := "123 Elm St",
                      items := ["item1", "item2"], trackingNumber := "1234567890" }
                    { emailSent := true, message := "Your order has been confirmed. Your items will be delivered to 123 Elm St with tracking number 1234567890" } := by
  unfold Spec; decide
