import ContractForge
open ContractForge

-- REQ-8: Results will be arranged in length/date/alphabetical order by clicking on the column headers.
-- compiles: True · rejects_bad_example: None · checked: False

structure Video where
  title   : String
  length  : Nat
  date    : Nat
  order   : String
  deriving DecidableEq, Repr

structure Input where
  videos : List Video
  order  : String
  deriving DecidableEq, Repr

structure Output where
  results : List Video
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.order ∈ ["length", "date", "title"]
  post := fun i o =>
    List.Pairwise (fun a b => a.order ≤ b.order) o.results ∧
    (i.order = "length" → List.Pairwise (·.length ≤ ·.length) o.results) ∧
    (i.order = "date" → List.Pairwise (·.date ≤ ·.date) o.results) ∧
    (i.order = "title" → List.Pairwise (fun a b => a.title < b.title) o.results)

example : Spec.pre { videos := [{ title := "A", length := 10, date := 20230101, order := "length" },
                                 { title := "B", length := 20, date := 20230102, order := "length" }],
                     order := "length" } ∧
          Spec.post { videos := [{ title := "A", length := 10, date := 20230101, order := "length" },
                                  { title := "B", length := 20, date := 20230102, order := "length" }],
                      order := "length" }
                    { results := [{ title := "A", length := 10, date := 20230101, order := "length" },
                                  { title := "B", length := 20, date := 20230102, order := "length" }] } := by
  unfold Spec; decide
