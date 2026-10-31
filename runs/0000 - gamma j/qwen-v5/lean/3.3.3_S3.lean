-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- checked: True

structure Input where
  cart : List String
  action : String
  product : String
  deriving DecidableEq, Repr

structure Output where
  cart : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action = "add" ∨ i.action = "remove" ∧ i.product ≠ ""
  post := fun i o => o.cart = 
    if i.action = "add" then i.cart ++ [i.product]
    else if i.action = "remove" then i.cart.filter (· ≠ i.product)
    else i.cart

example : Spec.pre { cart := ["A1", "A2"], action := "add", product := "A3" } ∧
          Spec.post { cart := ["A1", "A2"], action := "add", product := "A3" }
                     { cart := ["A1", "A2", "A3"] } := by
  unfold Spec; decide

example : Spec.pre { cart := ["A1", "A2"], action := "remove", product := "A2" } ∧
          Spec.post { cart := ["A1", "A2"], action := "remove", product := "A2" }
                     { cart := ["A1"] } := by
  unfold Spec; decide
