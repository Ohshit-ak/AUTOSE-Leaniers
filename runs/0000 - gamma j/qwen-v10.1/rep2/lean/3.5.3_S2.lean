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
  includeOutofStock : Bool
  deriving DecidableEq, Repr

structure Output where
  results : List Product
  message : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its source is switched on,
-- and it is not filtered out (out of stock is never shown if includeOutofStock is false)
def Wanted (i : Input) (it : Product) : Bool :=
  it.name.toLower.contains i.query.toLower && (i.includeOutofStock || 0 < it.stock)

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.products ∧ Wanted i it = true) ∧
    (o.results.length < 100 → ∀ it ∈ i.products, Wanted i it = true → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.price ≤ b.price) o.results ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "laptop", includeOutofStock := false,
                     products := [{ name := "Laptop", price := 500, stock := 10 },
                                  { name := "Tablet", price := 300, stock := 0 }] } ∧
          Spec.post { query := "laptop", includeOutofStock := false,
                      products := [{ name := "Laptop", price := 500, stock := 10 },
                                   { name := "Tablet", price := 300, stock := 0 }] }
                    { results := [{ name := "Laptop", price := 500, stock := 10 }], message := "" } := by
  unfold Spec; decide
