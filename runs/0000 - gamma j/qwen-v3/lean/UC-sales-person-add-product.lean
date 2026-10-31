-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- checked: True

structure Input where
  productCode : String
  productName : String
  productPrice : Nat
  productStock : Nat
  deriving DecidableEq, Repr

structure Output where
  productAdded : Bool
  productPageCreated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productCode.length = 6 ∧
                   i.productName.length > 0 ∧
                   0 < i.productPrice ∧
                   0 ≤ i.productStock
  post := fun i o => o.productAdded = true ∧
                     o.productPageCreated = true

example : Spec.pre { productCode := "P12345", productName := "Gadget", productPrice := 100, productStock := 50 } ∧
          Spec.post { productCode := "P12345", productName := "Gadget", productPrice := 100, productStock := 50 }
                    { productAdded := true, productPageCreated := true } := by
  unfold Spec; decide
