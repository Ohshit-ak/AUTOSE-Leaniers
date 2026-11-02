import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  name : String
  category : String
  price : Nat
  deriving DecidableEq, Repr

structure SearchCriteria where
  name : String
  category : String
  priceMin : Option Nat
  priceMax : Option Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  criteria : SearchCriteria
  deriving DecidableEq, Repr

structure Output where
  matchingProducts : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.matchingProducts = [] ↔ (i.criteria.name = "" ∧ i.criteria.category = "" ∧ i.criteria.priceMin.isNone ∧ i.criteria.priceMax.isNone)) ∧
                     (o.matchingProducts ≠ [] ↔
                       (i.criteria.name ≠ "" ∨ i.criteria.category ≠ "" ∨ i.criteria.priceMin.isSome ∨ i.criteria.priceMax.isSome) ∧
                       o.matchingProducts = i.products.filter (fun p =>
                         (i.criteria.name = "" ∨ p.name = i.criteria.name) ∧
                         (i.criteria.category = "" ∨ p.category = i.criteria.category) ∧
                         (i.criteria.priceMin.isNone ∨ p.price ≥ i.criteria.priceMin.getD 0) ∧
                         (i.criteria.priceMax.isNone ∨ p.price ≤ i.criteria.priceMax.getD 0)))

example : Spec.pre { products := [{ name := "Laptop", category := "Electronics", price := 1000 },
                                   { name := "Shirt", category := "Apparel", price := 50 }],
                     criteria := { name := "", category := "", priceMin := none, priceMax := none } } ∧
          Spec.post { products := [{ name := "Laptop", category := "Electronics", price := 1000 },
                                    { name := "Shirt", category := "Apparel", price := 50 }],
                      criteria := { name := "", category := "", priceMin := none, priceMax := none } }
                    { matchingProducts := [] } := by
  unfold Spec; decide

example : Spec.pre { products := [{ name := "Laptop", category := "Electronics", price := 1000 },
                                   { name := "Shirt", category := "Apparel", price := 50 }],
                     criteria := { name := "Laptop", category := "Electronics", priceMin := some 900, priceMax := none } } ∧
          Spec.post { products := [{ name := "Laptop", category := "Electronics", price := 1000 },
                                    { name := "Shirt", category := "Apparel", price := 50 }],
                      criteria := { name := "Laptop", category := "Electronics", priceMin := some 900, priceMax := none } }
                    { matchingProducts := [{ name := "Laptop", category := "Electronics", price := 1000 }] } := by
  unfold Spec; decide
