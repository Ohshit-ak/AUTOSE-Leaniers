-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- checked: True

structure Input where
  orderTotal : Nat
  tax        : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmation : Bool
  totalWithTax : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.orderTotal
  post := fun i o => o.confirmation = true ∧
                     o.totalWithTax = i.orderTotal + i.tax

example : Spec.pre { orderTotal := 100, tax := 10 } ∧
          Spec.post { orderTotal := 100, tax := 10 }
                    { confirmation := true, totalWithTax := 110 } := by
  unfold Spec; decide
