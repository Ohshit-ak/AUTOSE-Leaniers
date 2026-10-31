-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- checked: False

structure Input where
  category : String
  deriving DecidableEq, Repr

structure Output where
  category : String
  subCategories : List String
  products : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.category = i.category ∧
                     o.subCategories.Nodup ∧
                     o.products.Nodup ∧
                     o.subCategories.all (fun sc => sc = i.category ++ "://" ++ sc) ∧
                     o.products.all (fun p => p = i.category ++ "://" ++ p) ∧
                     o.subCategories ++ o.products = i.category :: o.subCategories ++ o.products

example : Spec.pre { category := "Electronics" } ∧
          Spec.post { category := "Electronics",
                      subCategories := ["Electronics://Smartphones", "Electronics://Laptops"],
                      products := ["Electronics://Smartphones://iPhone", "Electronics://Laptops://MacBook"] } := by
  unfold Spec; decide
