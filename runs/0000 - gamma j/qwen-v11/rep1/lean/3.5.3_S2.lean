import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  deriving DecidableEq, Repr

structure Input where
  query          : String
  products       : List Product
  minPrice       : Option Nat
  maxPrice       : Option Nat
  minStock       : Option Nat
  sortCriteria   : String
  deriving DecidableEq, Repr

structure Output where
  results : List Product
  message : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its price is within the range,
-- its stock is sufficient, and it is not filtered out by the sort criteria
def Wanted (i : Input) (p : Product) : Bool :=
  p.name.contains i.query && 
  (i.minPrice.isNone ∨ p.price ≥ i.minPrice.get) ∧
  (i.maxPrice.isNone ∨ p.price ≤ i.maxPrice.get) ∧
  (i.minStock.isNone ∨ p.stock ≥ i.minStock.get)

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ p ∈ o.results, p ∈ i.products ∧ Wanted i p = true) ∧
    (o.results.length < 100 → ∀ p ∈ i.products, Wanted i p = true → p ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    (i.sortCriteria = "price" → List.Pairwise (fun a b => a.price ≤ b.price) o.results) ∧
    (i.sortCriteria = "stock" → List.Pairwise (fun a b => a.stock ≤ b.stock) o.results) ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "laptop", products := [{ name := "laptop", price := 500, stock := 10 },
                                                      { name := "tablet", price := 300, stock := 20 }],
                     minPrice := some 400, maxPrice := none, minStock := some 5,
                     sortCriteria := "price" } ∧
          Spec.post { query := "laptop", products := [{ name := "laptop", price := 500, stock := 10 },
                                                       { name := "tablet", price := 300, stock := 20 }],
                      minPrice := some 400, maxPrice := none, minStock := some 5,
                      sortCriteria := "price" }
                    { results := [{ name := "laptop", price := 500, stock := 10 }], message := "" } := by
  unfold Spec; decide
