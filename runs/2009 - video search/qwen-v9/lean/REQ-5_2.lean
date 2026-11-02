import ContractForge
open ContractForge

-- REQ-5#2: Query to video hosting sites will retrieve full video name, length, date posted and a link to the video itself.
-- compiles: True · rejects_bad_example: True · checked: True

structure Video where
  name     : String
  length   : Nat
  date     : String
  link     : String
  deriving DecidableEq, Repr

structure Input where
  query          : String
  sites          : List String
  videos         : List Video
  deriving DecidableEq, Repr

structure Output where
  results : List Video
  deriving DecidableEq, Repr

def Wanted (i : Input) (v : Video) : Bool :=
  v.name == i.query

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ "" ∧ i.sites.Nodup
  post := fun i o =>
    (∀ v ∈ o.results, v ∈ i.videos ∧ Wanted i v = true) ∧
    (o.results.length < 100 → ∀ v ∈ i.videos, Wanted i v = true → v ∈ o.results) ∧
    o.results.length ≤ 100

example : Spec.pre { query := "Lean", sites := ["youtube.com", "vimeo.com"], videos := [{ name := "Lean", length := 5, date := "2023-10-01", link := "https://www.youtube.com/watch?v=1234567890" },
                                                                                         { name := "Lean", length := 10, date := "2023-10-02", link := "https://vimeo.com/1234567890" }] } ∧
          Spec.post { query := "Lean", sites := ["youtube.com", "vimeo.com"], videos := [{ name := "Lean", length := 5, date := "2023-10-01", link := "https://www.youtube.com/watch?v=1234567890" },
                                                                                         { name := "Lean", length := 10, date := "2023-10-02", link := "https://vimeo.com/1234567890" }] }
                    { results := [{ name := "Lean", length := 5, date := "2023-10-01", link := "https://www.youtube.com/watch?v=1234567890" },
                                  { name := "Lean", length := 10, date := "2023-10-02", link := "https://vimeo.com/1234567890" }] } := by
  unfold Spec; decide
