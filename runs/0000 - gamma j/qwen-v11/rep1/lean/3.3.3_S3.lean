import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  name   : String
  price  : Nat
  deriving DecidableEq, Repr

structure Input where
  cart    : List Product
  removed : Option Product
  added   : Option Product
  deriving DecidableEq, Repr

structure Output where
  cart    : List Product
  removed : Option Product
  added   : Option Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.removed = none ∨ i.added = none
  post := fun i o => (o.removed = i.removed ∧ o.added = i.added) ∧
                     (o.cart.length = i.cart.length + (i.added.getD 0).length - (i.removed.getD 0).length) ∧
                     (∀ p ∈ o.cart, ∃ p' ∈ i.cart, p = p' ∧ p.price = p'.price) ∧
                     (∀ p ∈ i.cart, ∃ p' ∈ o.cart, p = p' ∧ p.price = p'.price)

example : Spec.pre { cart := [{ name := "book", price := 10 }], removed := none, added := none } ∧
          Spec.post { cart := [{ name := "book", price := 10 }], removed := none, added := none }
                    { cart := [{ name := "book", price := 10 }], removed := none, added := none } := by
  unfold Spec; decide
