-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- checked: True

structure Input where
  productCode : String
  productName : String
  productPrice : Nat
  productStock : Nat
  deriving DecidableEq, Repr

structure Output where
  productCode : String
  productName : String
  productPrice : Nat
  productStock : Nat
  productPageCreated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productCode ≠ "" ∧ i.productName ≠ "" ∧ 0 < i.productPrice ∧ 0 < i.productStock
  post := fun i o => o.productCode = i.productCode ∧
                     o.productName = i.productName ∧
                     o.productPrice = i.productPrice ∧
                     o.productStock = i.productStock ∧
                     o.productPageCreated = true

example : Spec.pre { productCode := "A1", productName := "Laptop", productPrice := 1000, productStock := 50 } ∧
          Spec.post { productCode := "A1", productName := "Laptop", productPrice := 1000, productStock := 50 }
                     { productCode := "A1", productName := "Laptop", productPrice := 1000, productStock := 50, productPageCreated := true } := by
  unfold Spec; decide
