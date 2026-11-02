import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Cart where
  items : List Product
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  action : String
  product : Option Product
  quantity : Option Nat
  deriving DecidableEq, Repr

structure Output where
  cart : Cart
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action = "add" ∨ i.action = "remove" ∨ i.action = "update"
  post := fun i o =>
    (i.action = "add" →
      ∃ p ∈ i.product.getD none, ∃ q ∈ i.quantity.getD 1, o.cart.items = i.cart.items ++ [p] ++ List.repeat q p)
    ∧
    (i.action = "remove" →
      ∃ p ∈ i.product.getD none, o.cart.items = i.cart.items.filter (fun x => x ≠ p))
    ∧
    (i.action = "update" →
      ∃ p ∈ i.product.getD none, ∃ q ∈ i.quantity.getD p.quantity, o.cart.items = i.cart.items.map (fun x => if x = p then { x with quantity := q } else x))

example : Spec.pre { cart := { items := [] }, action := "add", product := some { name := "Apple", price := 100 }, quantity := some 5 } ∧
          Spec.post { cart := { items := [{ name := "Apple", price := 100, quantity := 5 }] } }
                    { cart := { items := [{ name := "Apple", price := 100, quantity := 5 }] } } := by
  unfold Spec; decide

example : Spec.pre { cart := { items := [{ name := "Apple", price := 100, quantity := 5 }] }, action := "remove", product := some { name := "Apple", price := 100 }, quantity := none } ∧
          Spec.post { cart := { items := [] } }
                    { cart := { items := [] } } := by
  unfold Spec; decide

example : Spec.pre { cart := { items := [{ name := "Apple", price := 100, quantity := 5 }] }, action := "update", product := some { name := "Apple", price := 100 }, quantity := some 10 } ∧
          Spec.post { cart := { items := [{ name := "Apple", price := 100, quantity := 10 }] } }
                    { cart := { items := [{ name := "Apple", price := 100, quantity := 10 }] } } := by
  unfold Spec; decide
