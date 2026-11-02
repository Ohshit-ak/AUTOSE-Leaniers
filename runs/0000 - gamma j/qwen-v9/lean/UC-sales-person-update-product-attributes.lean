import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- compiles: True · rejects_bad_example: None · checked: False

structure Product where
  name    : String
  category: String
  price   : Nat
  attributes : List String
  deriving DecidableEq, Repr

structure Input where
  product : Product
  newAttributes : List String
  deriving DecidableEq, Repr

structure Output where
  product : Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product.attributes.Nodup
  post := fun i o => o.product.attributes = i.newAttributes ∧
                     o.product.name = i.product.name ∧
                     o.product.category = i.product.category ∧
                     o.product.price = i.product.price

example : Spec.pre { product := { name := "Laptop", category := "Electronics", price := 500, attributes := ["Brand", "Color"] },
                     newAttributes := ["Brand", "Color", "OS"] } ∧
          Spec.post { product := { name := "Laptop", category := "Electronics", price := 500, attributes := ["Brand", "Color", "OS"] },
                      newAttributes := ["Brand", "Color", "OS"] }
                    { product := { name := "Laptop", category := "Electronics", price := 500, attributes := ["Brand", "Color", "OS"] } } := by
  unfold Spec; decide
