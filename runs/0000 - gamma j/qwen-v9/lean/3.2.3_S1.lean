import ContractForge
open ContractForge

-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- compiles: True · rejects_bad_example: None · checked: True

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
                     ∀ c ∈ o.categories, c.items.Nodup ∧
                     (c.parent.isSome → ∃ sub ∈ o.categories, sub.parent = some c.id)

example : Spec.pre { categories := [] } ∧ Spec.post { categories := [] } { categories := [] } := by
  unfold Spec; decide
