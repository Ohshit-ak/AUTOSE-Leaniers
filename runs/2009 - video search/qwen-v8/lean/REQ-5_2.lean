import ContractForge
open ContractForge

-- REQ-5#2: Query to video hosting sites will retrieve full video name, length, date posted and a link to the video itself.
-- compiles: True · rejects_bad_example: None · checked: True

structure Video where
  name      : String
  length    : Nat
  datePosted: Nat  -- in days since epoch
  link      : String
  deriving DecidableEq, Repr

structure Input where
  siteName  : String
  query     : String
  deriving DecidableEq, Repr

structure Output where
  found     : Bool
  videos    : List Video
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.siteName ≠ "" ∧ i.query ≠ ""
  post := fun i o => o.found ↔
    ∃ v ∈ o.videos, v.name = i.query ∧
    o.videos.length > 0 ∧
    ∀ v ∈ o.videos, v.name ≠ "" ∧ 0 < v.length ∧ 0 ≤ v.datePosted ∧ v.link ≠ ""

example : Spec.pre { siteName := "YouTube", query := "Lean" } ∧ Spec.post { siteName := "YouTube", query := "Lean" } { found := false, videos := [{ name := "Lean Tutorial", length := 5, datePosted := 100, link := "https://www.youtube.com/watch?v=12345" }] } := by
  unfold Spec; decide
