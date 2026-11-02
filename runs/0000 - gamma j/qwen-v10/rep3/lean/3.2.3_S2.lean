import ContractForge
open ContractForge

-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Category where
  id : Nat
  name : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Product where
  id : Nat
  name : String
  category : Nat
  details : String
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
  post := fun i o => o.categories = i.categories ∧
                     o.products = i.products

example : Spec.pre { categories := [{ id := 1, name := "Electronics", parent := none },
                                      { id := 2, name := "Books", parent := none }],
                     products := [{ id := 1, name := "iPhone", category := 1, details := "Smartphone" },
                                  { id := 2, name := "Harry Potter", category := 2, details := "Book" }] } ∧
          Spec.post { categories := [{ id := 1, name := "Electronics", parent := none },
                                      { id := 2, name := "Books", parent := none }],
                      products := [{ id := 1, name := "iPhone", category := 1, details := "Smartphone" },
                                   { id := 2, name := "Harry Potter", category := 2, details := "Book" }] }
                    { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Books", parent := none }],
                      products := [{ id := 1, name := "iPhone", category := 1, details := "Smartphone" },
                                   { id := 2, name := "Harry Potter", category := 2, details := "Book" }] } := by
  unfold Spec; decide
