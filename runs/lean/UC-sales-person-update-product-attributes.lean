-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- checked: None

structure Product where
  id : Nat
  name : String
  attributes : List String

structure Input where
  product : Product
  newAttributes : List String

def Spec : Contract Input Unit where
  pre input := 
    input.product.attributes ≠ input.newAttributes
  post input _ := 
    input.product.attributes = input.newAttributes

example : Spec
| input _ => 
  let newAttributes := input.newAttributes
  let updatedProduct := input.product with attributes := newAttributes
  pure ()
