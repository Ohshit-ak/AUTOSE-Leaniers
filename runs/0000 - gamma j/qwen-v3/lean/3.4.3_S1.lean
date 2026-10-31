-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- checked: True

structure Input where
  orderTotal : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  orderID   : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.orderTotal
  post := fun i o => o.confirmed = true ∧ o.orderID = i.orderTotal

example : Spec.pre { orderTotal := 150 } ∧
          Spec.post { orderTotal := 150 } { confirmed := true, orderID := 150 } := by
  unfold Spec; decide
