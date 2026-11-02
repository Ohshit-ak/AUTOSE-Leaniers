import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.Nodup
  post := fun i o => o.cart.length = i.cart.length ∧
                     (∀ p ∈ i.cart, p ∈ o.cart) ∧
                     (∀ p ∈ o.cart, p ∈ i.cart)

example : Spec.pre { cart := [{ name := "book", price := 10 }, { name := "pen", price := 2 }] } ∧
          Spec.post { cart := [{ name := "book", price := 10 }, { name := "pen", price := 2 }] }
                    { cart := [{ name := "book", price := 10 }, { name := "pen", price := 2 }] } := by
  unfold Spec; decide
