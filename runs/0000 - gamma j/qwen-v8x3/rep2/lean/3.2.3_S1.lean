import ContractForge
open ContractForge

-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- compiles: True · rejects_bad_example: None · checked: True

structure Category where
  id    : Nat
  name  : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup
  post := fun i o => o.categories = i.categories ∧
                     o.categories.Nodup

example : Spec.pre { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Computers", parent := some 1 },
                                     { id := 3, name := "Laptops", parent := some 2 }] } ∧
          Spec.post { categories := [{ id := 1, name := "Electronics", parent := none },
                                      { id := 2, name := "Computers", parent := some 1 },
                                      { id := 3, name := "Laptops", parent := some 2 }] }
                    { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Computers", parent := some 1 },
                                     { id := 3, name := "Laptops", parent := some 2 }] } := by
  unfold Spec; decide
