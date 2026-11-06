import ContractForge
open ContractForge

-- REQ-5#2: Query to video hosting sites will retrieve full video name, length, date posted and a link to the video itself.
-- compiles: True · rejects_bad_example: True · checked: True

structure Video where
  name   : String
  length : Nat
  date   : Nat  -- in seconds since epoch
  link   : String
  deriving DecidableEq, Repr

structure Input where
  query          : String
  sites          : List String
  results        : List Video
  deriving DecidableEq, Repr

structure Output where
  videos : List Video
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ "" ∧ i.sites.Nodup
  post := fun i o => ∀ v ∈ o.videos, v ∈ i.results ∧
    (v.name = i.query) ∧
    (v.length > 0) ∧
    (v.date > 0) ∧
    (v.link ≠ "")

example : Spec.pre { query := "Lean tutorial", sites := ["youtube.com", "vimeo.com"], results := [] } ∧ Spec.post { query := "Lean tutorial", sites := ["youtube.com", "vimeo.com"], results := [] } { videos := [] } := by
  unfold Spec; decide
