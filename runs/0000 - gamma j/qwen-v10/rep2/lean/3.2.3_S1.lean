import ContractForge
open ContractForge

-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- compiles: True · rejects_bad_example: True · checked: True

structure Category where
  id     : Nat
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Product where
  id     : Nat
  name   : String
  price  : Nat
  category : Nat
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
  post := fun i o => o.categories = i.categories ∧ o.products = i.products

example : Spec.pre { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Computers", parent := some 1 },
                                     { id := 3, name := "Smartphones", parent := some 2 }],
                     products := [{ id := 10, name := "iPhone", price := 1000, category := 3 },
                                  { id := 20, name := "MacBook", price := 1500, category := 2 }] } ∧
          Spec.post { categories := [{ id := 1, name := "Electronics", parent := none },
                                      { id := 2, name := "Computers", parent := some 1 },
                                      { id := 3, name := "Smartphones", parent := some 2 }],
                      products := [{ id := 10, name := "iPhone", price := 1000, category := 3 },
                                   { id := 20, name := "MacBook", price := 1500, category := 2 }] }
                    { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Computers", parent := some 1 },
                                     { id := 3, name := "Smartphones", parent := some 2 }],
                      products := [{ id := 10, name := "iPhone", price := 1000, category := 3 },
                                   { id := 20, name := "MacBook", price := 1500, category := 2 }] } := by
  unfold Spec; decide
