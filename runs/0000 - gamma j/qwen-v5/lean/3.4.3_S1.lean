-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- checked: True

structure Input where
  orderConfirmed : Bool
  orderTotal     : Nat
  deriving DecidableEq, Repr

structure Output where
  orderConfirmed : Bool
  orderTotal     : Nat
  paymentProcessed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderConfirmed = false ∧ 0 < i.orderTotal
  post := fun i o => o.orderConfirmed = true ∧ o.orderTotal = i.orderTotal ∧ o.paymentProcessed = true

example : Spec.pre { orderConfirmed := false, orderTotal := 100 } ∧
          Spec.post { orderConfirmed := false, orderTotal := 100 }
                    { orderConfirmed := true, orderTotal := 100, paymentProcessed := true } := by
  unfold Spec; decide
