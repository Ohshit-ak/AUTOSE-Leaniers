import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  name : String
  price : Nat
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
                     o.product.price = i.product.price

example : Spec.pre { product := { name := "Laptop", price := 1000, attributes := ["Electronics", "Laptop"] },
                     newAttributes := ["Electronics", "Laptop", "High Performance"] } ∧
          Spec.post { product := { name := "Laptop", price := 1000, attributes := ["Electronics", "Laptop"] },
                      newAttributes := ["Electronics", "Laptop", "High Performance"] }
                    { product := { name := "Laptop", price := 1000, attributes := ["Electronics", "Laptop", "High Performance"] } } := by
  unfold Spec; decide
