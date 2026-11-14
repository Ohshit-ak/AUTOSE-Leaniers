import ContractForge
open ContractForge

-- REQ-7#3: Any torrent result with a rating of less than 1 will not be displayed.
-- compiles: True · rejects_bad_example: True · checked: True

structure Item where
  name   : String
  source : String
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  query          : String
  items          : List Item
  includeArchive : Bool
  deriving DecidableEq, Repr

structure Output where
  results : List Item
  message : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its source is switched on,
-- and its rating is not less than 1
def Wanted (i : Input) (it : Item) : Bool :=
  it.name == i.query && (i.includeArchive || it.source != "archive") && 1 ≤ it.rating

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.items ∧ Wanted i it = true) ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "cats", items := [{ name := "cats", source := "web", rating := 0 }, { name := "cats", source := "archive", rating := 1 }], includeArchive := false } ∧ Spec.post { query := "cats", items := [{ name := "cats", source := "web", rating := 0 }, { name := "cats", source := "archive", rating := 1 }], includeArchive := false } { results := [], message := "No results were found." } := by
  unfold Spec; decide
