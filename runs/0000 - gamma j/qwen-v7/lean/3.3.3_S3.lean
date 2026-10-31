import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  id : Nat
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Cart where
  items : List Product
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  productToAdd : Option Product
  productToRemove : Option Product
  deriving DecidableEq, Repr

structure Output where
  cart : Cart
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.cart.items = 
    (if i.productToAdd.isSome then
      i.cart.items ++ [i.productToAdd.get]
    else
      i.cart.items) // Add product to cart
    =
    (if i.productToRemove.isSome then
      i.cart.items.filter (fun p => p ≠ i.productToRemove.get)
    else
      i.cart.items) // Remove product from cart

example : Spec.pre { cart := { items := [] }, productToAdd := none, productToRemove := none } ∧
          Spec.post { cart := { items := [] }, productToAdd := none, productToRemove := none }
                    { cart := { items := [] } } := by
  unfold Spec; decide
