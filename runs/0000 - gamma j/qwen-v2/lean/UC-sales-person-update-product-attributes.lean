-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- checked: True

structure Input where
  productId : Nat
  attributes : List String
  deriving DecidableEq, Repr

structure Output where
  productId : Nat
  updatedAttributes : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attributes.length > 0
  post := fun i o => o.productId = i.productId ∧
                     o.updatedAttributes = i.attributes

example : Spec.pre { productId := 1, attributes := ["color: blue", "size: medium"] } ∧
          Spec.post { productId := 1, attributes := ["color: blue", "size: medium"] }
                    { productId := 1, updatedAttributes := ["color: blue", "size: medium"] } := by
  unfold Spec; decide
