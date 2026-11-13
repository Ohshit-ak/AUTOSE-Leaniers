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
  post := fun i o => o.cart = i.cart

example : Spec.pre { cart := [{ name := "book", price := 10 }] } ∧
          Spec.post { cart := [{ name := "book", price := 10 }] }
                    { cart := [{ name := "book", price := 10 }] } := by
  unfold Spec; decide
