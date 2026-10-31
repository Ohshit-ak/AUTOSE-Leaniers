-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- checked: True

structure Input where
  orderDetails : String
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  orderDetails : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.sentEmail = true ∧
                     i.orderDetails = o.orderDetails

example : Spec.pre { orderDetails := "Order for 2x Widget, total: $10.00" } ∧
          Spec.post { orderDetails := "Order for 2x Widget, total: $10.00" }
                    { sentEmail := true, orderDetails := "Order for 2x Widget, total: $10.00" } := by
  unfold Spec; decide
