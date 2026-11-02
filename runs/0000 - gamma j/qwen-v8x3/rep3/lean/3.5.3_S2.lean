import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  code : String
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  searchCriteria : String
  deriving DecidableEq, Repr

structure Output where
  matchingProducts : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.searchCriteria ≠ ""
  post := fun i o => o.matchingProducts.Nodup ∧
                     o.matchingProducts.all (fun p => i.products.contains p) ∧
                     (o.matchingProducts = [] ↔
                      i.products.all (fun p => ¬(p.name.toLower.contains i.searchCriteria.toLower) ∧
                                              ¬(p.code.toLower.contains i.searchCriteria.toLower)))

example : Spec.pre { products := [], searchCriteria := "a" } ∧ Spec.post { products := [], searchCriteria := "a" } { matchingProducts := [] } := by
  unfold Spec; decide
