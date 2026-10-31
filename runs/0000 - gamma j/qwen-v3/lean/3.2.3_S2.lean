-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- checked: True

structure Input where
  categoryUpdate : Option String
  productCategoryUpdate : Option (String × String)
  productDetailsUpdate : Option (String × String × String)
  deriving DecidableEq, Repr

structure Output where
  categoryUpdated : Bool
  productCategoryUpdated : Bool
  productDetailsUpdated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categoryUpdate.isSome ∨ i.productCategoryUpdate.isSome ∨ i.productDetailsUpdate.isSome
  post := fun i o => o.categoryUpdated = i.categoryUpdate.isSome ∧
                     o.productCategoryUpdated = i.productCategoryUpdate.isSome ∧
                     o.productDetailsUpdated = i.productDetailsUpdate.isSome

example : Spec.pre { categoryUpdate := some "Electronics", productCategoryUpdate := none, productDetailsUpdate := none } ∧
          Spec.post { categoryUpdate := some "Electronics", productCategoryUpdate := none, productDetailsUpdate := none }
                     { categoryUpdated := true, productCategoryUpdated := false, productDetailsUpdated := false } := by
  unfold Spec; decide
