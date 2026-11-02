import ContractForge
open ContractForge

-- REQ-1#2: Streaming search will share the same search bar with the torrent search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query          : String
  torrents       : List String
  videos         : List String
  deriving DecidableEq, Repr

structure Output where
  torrents       : List String
  videos         : List String
  deriving DecidableEq, Repr

-- The query is used for both torrent and video searches
def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ t ∈ o.torrents, t ∈ i.torrents) ∧
    (∀ v ∈ o.videos, v ∈ i.videos) ∧
    (o.torrents.length + o.videos.length = i.torrents.length + i.videos.length)

example : Spec.pre { query := "example", torrents := ["t1", "t2"], videos := ["v1", "v2"] } ∧
          Spec.post { query := "example", torrents := ["t1", "t2"], videos := ["v1", "v2"] }
                    { torrents := ["t1", "t2"], videos := ["v1", "v2"] } := by
  unfold Spec; decide
