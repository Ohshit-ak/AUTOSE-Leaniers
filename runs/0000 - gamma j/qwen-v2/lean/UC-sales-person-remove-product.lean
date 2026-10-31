-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.
-- checked: True

structure Input where
  productId : Nat
  productTitle : String
  productPrice : Nat
  productStock : Nat
  deriving DecidableEq, Repr

structure Output where
  productDeleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productId ≠ 0
  post := fun i o => o.productDeleted = true ∧
                     (o.productDeleted = false →
                      i.productTitle = "valid title" ∧
                      i.productPrice > 0 ∧
                      i.productStock ≥ 0)

example : Spec.pre { productId := 1, productTitle := "Example Product", productPrice := 100, productStock := 50 } ∧
          Spec.post { productId := 1, productTitle := "Example Product", productPrice := 100, productStock := 50 }
                    { productDeleted := true } := by
  unfold Spec; decide
