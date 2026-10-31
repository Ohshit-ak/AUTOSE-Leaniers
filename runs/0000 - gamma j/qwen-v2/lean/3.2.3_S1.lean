-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- checked: True

structure Input where
  category : String
  subCategories : List String
  products : List String
  deriving DecidableEq, Repr

structure Output where
  category : String
  subCategories : List String
  products : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.category ≠ ""
  post := fun i o => o.category = i.category ∧
                     o.subCategories = i.subCategories ∧
                     o.products = i.products

example : Spec.pre { category := "Electronics", subCategories := ["Cameras", "Laptops"], products := ["DSLR", "Notebook"] } ∧
          Spec.post { category := "Electronics", subCategories := ["Cameras", "Laptops"], products := ["DSLR", "Notebook"] }
                     { category := "Electronics", subCategories := ["Cameras", "Laptops"], products := ["DSLR", "Notebook"] } := by
  unfold Spec; decide
