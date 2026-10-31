-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- checked: True

structure Input where
  orderCorrect : Bool
  deriving DecidableEq, Repr

structure Output where
  orderCorrect : Bool
  revised      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ¬i.orderCorrect
  post := fun i o => o.orderCorrect = true ∧ o.revised = true

example : Spec.pre { orderCorrect := false } ∧
          Spec.post { orderCorrect := false } { orderCorrect := true, revised := true } := by
  unfold Spec; decide
