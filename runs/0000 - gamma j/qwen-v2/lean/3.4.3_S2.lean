-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- checked: True

structure Input where
  orderCorrect : Bool
  fieldsToUpdate : List String
  deriving DecidableEq, Repr

structure Output where
  orderCorrect : Bool
  fieldsUpdated : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ¬i.orderCorrect
  post := fun i o => o.orderCorrect = true ∧
                     o.fieldsUpdated = i.fieldsToUpdate

example : Spec.pre { orderCorrect := false, fieldsToUpdate := ["product", "quantity"] } ∧
          Spec.post { orderCorrect := false, fieldsToUpdate := ["product", "quantity"] }
                     { orderCorrect := true, fieldsUpdated := ["product", "quantity"] } := by
  unfold Spec; decide
