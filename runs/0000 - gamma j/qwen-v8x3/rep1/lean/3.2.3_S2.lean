import ContractForge
open ContractForge

-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Category where
  id : Nat
  name : String
  products : List Nat
  deriving DecidableEq, Repr

structure Product where
  id : Nat
  name : String
  price : Nat
  inStock : Nat
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup ∧ i.products.Nodup
  post := fun i o => o.categories = i.categories ∧ o.products = i.products

example : Spec.pre { categories := [{ id := 1, name := "Electronics", products := [101] },
                                      { id := 2, name := "Books", products := [201] }],
                     products := [{ id := 101, name := "Phone", price := 500, inStock := 10 },
                                  { id := 201, name := "Book", price := 20, inStock := 50 }] } ∧
          Spec.post { categories := [{ id := 1, name := "Electronics", products := [101] },
                                      { id := 2, name := "Books", products := [201] }],
                      products := [{ id := 101, name := "Phone", price := 500, inStock := 10 },
                                   { id := 201, name := "Book", price := 20, inStock := 50 }] }
                    { categories := [{ id := 1, name := "Electronics", products := [101] },
                                     { id := 2, name := "Books", products := [201] }],
                      products := [{ id := 101, name := "Phone", price := 500, inStock := 10 },
                                   { id := 201, name := "Book", price := 20, inStock := 50 }] } := by
  unfold Spec; decide
