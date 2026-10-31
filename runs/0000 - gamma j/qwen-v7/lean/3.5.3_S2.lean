import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  code : String
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure SearchCriteria where
  keyword : String
  minPrice : Option Nat
  maxPrice : Option Nat
  deriving DecidableEq, Repr

structure SearchResult where
  products : List Product
  found : Bool
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  criteria : SearchCriteria
  deriving DecidableEq, Repr

structure Output where
  results : SearchResult
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria.keyword ≠ ""
  post := fun i o => o.results.found ↔
    ∃ products ∈ i.products,
      (products.name.contains i.criteria.keyword) ∧
      (i.criteria.minPrice.isNone ∨ products.price ≥ i.criteria.minPrice.getD 0) ∧
      (i.criteria.maxPrice.isNone ∨ products.price ≤ i.criteria.maxPrice.getD 0)

example : Spec.pre { products := [{ code := "A1", name := "Laptop", price := 1000 },
                                   { code := "A2", name := "Mouse", price := 50 }],
                     criteria := { keyword := "Lap", minPrice := none, maxPrice := none } } ∧
          Spec.post { products := [{ code := "A1", name := "Laptop", price := 1000 },
                                    { code := "A2", name := "Mouse", price := 50 }],
                      criteria := { keyword := "Lap", minPrice := none, maxPrice := none } }
                    { results := { products := [{ code := "A1", name := "Laptop", price := 1000 }],
                                   found := true }, found := true } := by
  unfold Spec; decide
