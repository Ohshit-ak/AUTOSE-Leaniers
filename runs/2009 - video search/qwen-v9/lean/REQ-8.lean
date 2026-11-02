import ContractForge
open ContractForge

-- REQ-8: Results will be arranged in length/date/alphabetical order by clicking on the column headers.
-- compiles: False · rejects_bad_example: None · checked: False

structure Video where
  title   : String
  length  : Nat
  date    : Nat  -- in seconds since epoch
  deriving DecidableEq, Repr

structure Input where
  videos : List Video
  orderBy : String  -- "length", "date", "title"
  deriving DecidableEq, Repr

structure Output where
  results : List Video
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderBy ∈ ["length", "date", "title"]
  post := fun i o =>
    List.Pairwise (fun a b => a.length ≤ b.length) o.results ↔ i.orderBy = "length" ∧
    List.Pairwise (fun a b => a.date ≤ b.date) o.results ↔ i.orderBy = "date" ∧
    List.Pairwise (fun a b => a.title < b.title) o.results ↔ i.orderBy = "title"

example : Spec.pre { videos := [{ title := "A", length := 100, date := 1000 },
                                 { title := "B", length := 200, date := 2000 }],
                     orderBy := "length" } ∧
          Spec.post { videos := [{ title := "A", length := 100, date := 1000 },
                                 { title := "B", length := 200, date := 2000 }],
                     orderBy := "length" }
                    { results := [{ title := "A", length := 100, date := 1000 },
                                  { title := "B", length := 200, date := 2000 }] } := by
  unfold Spec; decide
