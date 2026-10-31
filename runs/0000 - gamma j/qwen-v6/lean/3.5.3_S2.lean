import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  code : String
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure SearchCriteria where
  name : Option String
  code : Option String
  minPrice : Option Nat
  maxPrice : Option Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  criteria : SearchCriteria
  deriving DecidableEq, Repr

structure Output where
  matchingProducts : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.products.Nodup
  post := fun i o => o.matchingProducts = i.products.filter (fun p =>
    (i.criteria.name.isNone ∨ i.criteria.name.getD "" = p.name) ∧
    (i.criteria.code.isNone ∨ i.criteria.code.getD "" = p.code) ∧
    (i.criteria.minPrice.isNone ∨ i.criteria.minPrice.getD 0 ≤ p.price) ∧
    (i.criteria.maxPrice.isNone ∨ p.price ≤ i.criteria.maxPrice.getD 0))

example : Spec.pre { products := [], criteria := { name := none, code := none, minPrice := none, maxPrice := none } } ∧ Spec.post { products := [], criteria := { name := none, code := none, minPrice := none, maxPrice := none } } { matchingProducts := [] } := by
  unfold Spec; decide
