-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.
-- checked: True

structure Input where
  productId : Nat
  productTitle : String
  productPrice : Nat
  deriving DecidableEq, Repr

structure Output where
  productDeleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productId ≠ 0 ∧ i.productTitle ≠ "" ∧ 0 < i.productPrice
  post := fun i o => o.productDeleted = true

example : Spec.pre { productId := 123, productTitle := "Gadget", productPrice := 999 } ∧
          Spec.post { productId := 123, productTitle := "Gadget", productPrice := 999 }
                    { productDeleted := true } := by
  unfold Spec; decide
