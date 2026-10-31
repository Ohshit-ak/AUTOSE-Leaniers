-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- checked: True

structure Input where
  orderCorrect : Bool
  items        : List String
  deriving DecidableEq, Repr

structure Output where
  orderCorrect : Bool
  items        : List String
  revised      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ¬i.orderCorrect
  post := fun i o => o.orderCorrect = true ∧
                     o.items = i.items ∧
                     o.revised = true

example : Spec.pre { orderCorrect := false, items := ["Item1", "Item2"] } ∧
          Spec.post { orderCorrect := false, items := ["Item1", "Item2"] }
                     { orderCorrect := true, items := ["Item1", "Item2"], revised := true } := by
  unfold Spec; decide
