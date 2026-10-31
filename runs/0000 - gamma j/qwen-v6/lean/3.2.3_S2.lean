import ContractForge
open ContractForge

-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- compiles: True · rejects_bad_example: None · checked: True

structure Category where
  name : String
  deriving DecidableEq, Repr

structure Product where
  name : String
  details : String
  categories : List Category
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  products   : List Product
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  products   : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup ∧ i.products.Nodup
  post := fun i o => o.categories = i.categories ∧
                     o.products = i.products

example : Spec.pre { categories := [{ name := "Electronics" }], products := [{ name := "Laptop", details := "15-inch", categories := [{ name := "Electronics" }] }] } ∧
          Spec.post { categories := [{ name := "Electronics" }], products := [{ name := "Laptop", details := "15-inch", categories := [{ name := "Electronics" }] }] }
                     { categories := [{ name := "Electronics" }], products := [{ name := "Laptop", details := "15-inch", categories := [{ name := "Electronics" }] }] } := by
  unfold Spec; decide
