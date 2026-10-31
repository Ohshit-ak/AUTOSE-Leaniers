import ContractForge
open ContractForge

-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- compiles: True · rejects_bad_example: None · checked: False

structure Category where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Product where
  id : Nat
  name : String
  price : Nat
  inStock : Nat
  deriving DecidableEq, Repr

structure CategoryProduct where
  categoryId : Nat
  productId : Nat
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  products : List Product
  categoryProducts : List CategoryProduct
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  products : List Product
  categoryProducts : List CategoryProduct
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup ∧ i.products.Nodup ∧ i.categoryProducts.Nodup
  post := fun i o => o.categories = i.categories ∧
                     o.products = i.products ∧
                     o.categoryProducts = i.categoryProducts

example : Spec.pre { categories := [{ id := 1, name := "Electronics" }],
                     products := [{ id := 1, name := "Laptop", price := 1000, inStock := 5 }],
                     categoryProducts := [{ categoryId := 1, productId := 1 }] } ∧
          Spec.post { categories := [{ id := 1, name := "Electronics" }],
                      products := [{ id := 1, name := "Laptop", price := 1000, inStock := 5 }],
                      categoryProducts := [{ categoryId := 1, productId := 1 }] }
                    { categories := [{ id := 1, name := "Electronics" }],
                      products := [{ id := 1, name := "Laptop", price := 1000, inStock := 5 }],
                      categoryProducts := [{ categoryId := 1, productId := 1 }] } := by
  unfold Spec; decide
