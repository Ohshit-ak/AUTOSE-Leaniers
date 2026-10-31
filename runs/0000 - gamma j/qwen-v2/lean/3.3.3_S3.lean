-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- checked: True

structure Input where
  cart : List Nat
  action : String
  deriving DecidableEq, Repr

structure Output where
  cart : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["add", "remove"]
  post := fun i o => i.action = "add" → o.cart = i.cart ++ [i.cart.length]
    ∧ i.action = "remove" → o.cart = i.cart.filter (· ≠ i.cart.length)

example : Spec.pre { cart := [1, 2, 3], action := "add" } ∧
          Spec.post { cart := [1, 2, 3], action := "add" } { cart := [1, 2, 3, 3] } := by
  unfold Spec; decide

example : Spec.pre { cart := [1, 2, 3], action := "remove" } ∧
          Spec.post { cart := [1, 2, 3], action := "remove" } { cart := [1, 2] } := by
  unfold Spec; decide
