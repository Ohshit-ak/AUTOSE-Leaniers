import ContractForge
open ContractForge

-- 3.5.1/S4: By writing just one character the database will present all data which contains it or are related with it.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  query : String
  items : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.items ∧ it.toList.any (fun c => c == i.query.toList.head)) ∧
    (o.results.length ≤ 100)

example : Spec.pre { query := "a", items := ["apple", "banana", "apricot", "orange"] } ∧
          Spec.post { query := "a", items := ["apple", "banana", "apricot", "orange"] }
                    { results := ["apple", "apricot"] } := by
  unfold Spec; decide
