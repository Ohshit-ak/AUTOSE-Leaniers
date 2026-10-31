-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- checked: False

structure Input where
  cart : List String
  action : String
  product : String
  deriving DecidableEq, Repr

structure Output where
  cart : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action = "add" ∨ i.action = "remove" ∨ i.product ∈ i.cart
  post := fun i o => i.action = "add" → o.cart = i.cart ++ [i.product]
    ∧ i.action = "remove" → o.cart = i.cart.filter (· ≠ i.product)

example : Spec.pre { cart := ["apple", "banana"], action := "add", product := "orange" } ∧
          Spec.post { cart := ["apple", "banana", "orange"], action := "add", product := "orange" }
                     { cart := ["apple", "banana", "orange"] } := by
  unfold Spec; decide

example : Spec.pre { cart := ["apple", "banana"], action := "remove", product := "banana" } ∧
          Spec.post { cart := ["apple"], action := "remove", product := "banana" }
                     { cart := ["apple"] } := by
  unfold Spec; decide
