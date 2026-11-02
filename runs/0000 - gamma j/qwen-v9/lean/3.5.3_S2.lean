import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  name   : String
  price  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  query          : String
  products       : List Product
  includeArchive : Bool
  deriving DecidableEq, Repr

structure Output where
  results : List Product
  message : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its source is switched on,
-- and it is not filtered out (rating 0 is never shown)
def Wanted (i : Input) (p : Product) : Bool :=
  p.name.toLower.contains i.query.toLower && (i.includeArchive || p.rating > 0)

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ p ∈ o.results, p ∈ i.products ∧ Wanted i p = true) ∧
    (o.results.length < 100 → ∀ p ∈ i.products, Wanted i p = true → p ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.rating ≥ b.rating) o.results ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "laptop", includeArchive := false,
                     products := [{ name := "Laptop", price := 500, rating := 4 },
                                  { name := "Tablet", price := 300, rating := 3 }] } ∧
          Spec.post { query := "laptop", includeArchive := false,
                      products := [{ name := "Laptop", price := 500, rating := 4 },
                                   { name := "Tablet", price := 300, rating := 3 }] }
                    { results := [{ name := "Laptop", price := 500, rating := 4 }], message := "" } := by
  unfold Spec; decide
