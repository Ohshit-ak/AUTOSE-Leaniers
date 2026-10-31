import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  code : String
  quantity : Nat
  deriving DecidableEq, Repr

structure ShoppingCart where
  items : List Product
  deriving DecidableEq, Repr

structure Input where
  cart : ShoppingCart
  productCode : String
  action : String
  quantity : Nat
  deriving DecidableEq, Repr

structure Output where
  cart : ShoppingCart
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productCode ≠ "" ∧ i.quantity > 0
  post := fun i o => (o.cart.items = i.cart.items ∧
    o.cart.items.Nodup ∧
    (∃ p ∈ o.cart.items, p.code = i.productCode ∧
      (i.action = "add" → p.quantity = i.quantity) ∧
      (i.action = "remove" → p.quantity = i.quantity - 1)) ↔
    True)

example : Spec.pre { cart := { items := [{ code := "A1", quantity := 8 }] }, productCode := "A1", action := "", quantity := 3 } ∧ Spec.post { cart := { items := [{ code := "A1", quantity := 8 }] }, productCode := "A1", action := "", quantity := 3 } { cart := { items := [{ code := "A1", quantity := 8 }] } } := by
  unfold Spec; decide
