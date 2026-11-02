import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: True · rejects_bad_example: None · checked: True

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
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its source is switched on,
-- and it is not filtered out (rating 0 is never shown)
def Wanted (i : Input) (it : Product) : Bool :=
  it.name.toLower.contains i.query.toLower && (i.includeArchive || it.rating > 0)

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.products ∧ Wanted i it = true) ∧
    (o.results.length < 100 → ∀ it ∈ i.products, Wanted i it = true → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.rating ≥ b.rating) o.results

example : Spec.pre { query := "laptop", products := [], includeArchive := false } ∧ Spec.post { query := "laptop", products := [], includeArchive := false } { results := [] } := by
  unfold Spec; decide
