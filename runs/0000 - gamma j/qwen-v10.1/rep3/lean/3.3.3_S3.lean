import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  action : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.Nodup
  post := fun i o => o.action = "add" →
    ∃ p ∈ i.cart, o.cart.contains p ∧ o.cart.count p = i.cart.count p + 1 ∧
    ∀ p' ∈ o.cart, p' ≠ p → o.cart.count p' = i.cart.count p'
    ∧
    o.action = "remove" →
    o.cart.contains i.cart.head ∧
    o.cart.count i.cart.head = i.cart.count i.cart.head - 1 ∧
    ∀ p' ∈ o.cart, p' ≠ i.cart.head → o.cart.count p' = i.cart.count p'
    ∧
    o.action = "no change" →
    o.cart = i.cart

example : Spec.pre { cart := [{ name := "A", price := 10 }, { name := "B", price := 20 }] } ∧
          Spec.post { cart := [{ name := "A", price := 10 }, { name := "B", price := 20 }] }
                    { action := "no change", cart := [{ name := "A", price := 10 }, { name := "B", price := 20 }] } := by
  unfold Spec; decide
