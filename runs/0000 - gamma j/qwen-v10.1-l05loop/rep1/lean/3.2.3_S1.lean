import ContractForge
open ContractForge

-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- compiles: True · rejects_bad_example: True · checked: True

structure Category where
  id       : Nat
  parent   : Option Nat
  name     : String
  items    : List String
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
                     ∀ c ∈ o.categories, c.items.Nodup

example : Spec.pre { categories := [{ id := 1, parent := none, name := "Electronics", items := ["TV", "Laptop"] },
                                      { id := 2, parent := some 1, name := "TVs", items := ["LED", "LCD"] }] } ∧
          Spec.post { categories := [{ id := 1, parent := none, name := "Electronics", items := ["TV", "Laptop"] },
                                      { id := 2, parent := some 1, name := "TVs", items := ["LED", "LCD"] }] }
                    { categories := [{ id := 1, parent := none, name := "Electronics", items := ["TV", "Laptop"] },
                                     { id := 2, parent := some 1, name := "TVs", items := ["LED", "LCD"] }] } := by
  unfold Spec; decide
