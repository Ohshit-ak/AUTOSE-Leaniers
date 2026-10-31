import ContractForge
open ContractForge

-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- compiles: True · rejects_bad_example: None · checked: True

structure Category where
  id     : Nat
  parent : Option Nat
  name   : String
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

example : Spec.pre { categories := [{ id := 1, parent := none, name := "Electronics" },
                                     { id := 2, parent := some 1, name := "Laptops" },
                                     { id := 3, parent := some 1, name := "Smartphones" }] } ∧
          Spec.post { categories := [{ id := 1, parent := none, name := "Electronics" },
                                      { id := 2, parent := some 1, name := "Laptops" },
                                      { id := 3, parent := some 1, name := "Smartphones" }] }
                    { categories := [{ id := 1, parent := none, name := "Electronics" },
                                     { id := 2, parent := some 1, name := "Laptops" },
                                     { id := 3, parent := some 1, name := "Smartphones" }] } := by
  unfold Spec; decide
