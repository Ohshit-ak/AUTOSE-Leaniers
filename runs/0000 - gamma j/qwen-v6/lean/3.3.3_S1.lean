import ContractForge
open ContractForge

-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  code : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  productCode : String
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  added : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productCode ≠ ""
  post := fun i o => o.added = true ↔
    ∃ p ∈ i.cart, p.code = i.productCode ∨
    i.cart.length < i.cart.length + 1 ∧
    o.cart = i.cart ++ [{ code := i.productCode, price := 100 }] -- IMPL: Price is hardcoded as 100 for simplicity

example : Spec.pre { cart := [], productCode := "A1" } ∧ Spec.post { cart := [], productCode := "A1" } { cart := [{ code := "A1", price := 100 }], added := false } := by
  unfold Spec; decide
