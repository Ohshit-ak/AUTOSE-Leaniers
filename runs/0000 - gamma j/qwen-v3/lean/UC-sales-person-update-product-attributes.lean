-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- checked: True

structure Input where
  productId : Nat
  attributes : String
  deriving DecidableEq, Repr

structure Output where
  productId : Nat
  updatedAttributes : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attributes.length ≤ 100
  post := fun i o => o.productId = i.productId ∧
                     o.updatedAttributes = i.attributes

example : Spec.pre { productId := 123, attributes := "New Attributes" } ∧
          Spec.post { productId := 123, attributes := "New Attributes" }
                    { productId := 123, updatedAttributes := "New Attributes" } := by
  unfold Spec; decide
