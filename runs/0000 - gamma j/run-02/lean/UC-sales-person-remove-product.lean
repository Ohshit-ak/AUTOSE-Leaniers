-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.
-- checked: True

structure Input where
  productCode : String
  productPage : String
  deriving DecidableEq, Repr

structure Output where
  productCode : String
  productPage : String
  deleted    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productCode.length = 6 ∧ i.productPage.length > 0
  post := fun i o => o.deleted = true ∧
                     (o.productCode = i.productCode ∧ o.productPage = "") ∧
                     (o.productCode ≠ i.productCode → o.productPage = i.productPage)

example : Spec.pre { productCode := "A12345", productPage := "Product A" } ∧
          Spec.post { productCode := "A12345", productPage := "Product A" }
                     { productCode := "A12345", productPage := "", deleted := true } := by
  unfold Spec; decide
