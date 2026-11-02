import ContractForge
open ContractForge

-- REQ-8: Results will be arranged in length/date/alphabetical order by clicking on the column headers.
-- compiles: True · rejects_bad_example: None · checked: False

structure Video where
  title   : String
  duration: Nat
  date    : String
  order   : String
  deriving DecidableEq, Repr

structure Input where
  videos  : List Video
  order   : String
  deriving DecidableEq, Repr

structure Output where
  results : List Video
  deriving DecidableEq, Repr

-- An item is in the results if its order matches the criteria
def InResults (i : Input) (v : Video) : Bool :=
  v.order = i.order

def Spec : Contract Input Output where
  pre  := fun i => i.order ∈ ["length", "date", "title"]
  post := fun i o =>
    List.Pairwise (fun a b => a.order ≤ b.order) o.results ∧
    (∀ v ∈ o.results, v ∈ i.videos ∧ InResults i v = true)

example : Spec.pre { videos := [{ title := "A", duration := 5, date := "2023-01-01", order := "title" },
                                 { title := "B", duration := 3, date := "2023-02-01", order := "title" }],
                     order := "title" } ∧
          Spec.post { videos := [{ title := "A", duration := 5, date := "2023-01-01", order := "title" },
                                  { title := "B", duration := 3, date := "2023-02-01", order := "title" }],
                      order := "title" }
                    { results := [{ title := "A", duration := 5, date := "2023-01-01", order := "title" },
                                  { title := "B", duration := 3, date := "2023-02-01", order := "title" }] } := by
  unfold Spec; decide
