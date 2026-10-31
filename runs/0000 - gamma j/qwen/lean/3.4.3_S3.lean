-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- checked: True

structure Input where
  orderDetails : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.sent = true ∧
                     (i.orderDetails.length ≤ 1000) ∧
                     (i.orderDetails.toList.all Char.isAlphanum = true)

example : Spec.pre { orderDetails := "" } ∧ Spec.post { orderDetails := "" } { sent := true } := by
  unfold Spec; decide
