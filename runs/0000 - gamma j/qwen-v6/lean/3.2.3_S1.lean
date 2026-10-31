import ContractForge
open ContractForge

-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- compiles: False · rejects_bad_example: None · checked: False

structure Category where
  name    : String
  categories : List Category
  products : List String
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup
  post := fun i o => o.categories = i.categories

example : Spec.pre { categories := [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
                                      { name := "Books", categories := [], products := ["Math", "Physics"] }] } ∧
          Spec.post { categories := [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
                                      { name := "Books", categories := [], products := ["Math", "Physics"] }] }
                    { categories := [{ name := "Electronics", categories := [], products := ["Phone", "Laptop"] },
                                     { name := "Books", categories := [], products := ["Math", "Physics"] }] } := by
  unfold Spec; decide
