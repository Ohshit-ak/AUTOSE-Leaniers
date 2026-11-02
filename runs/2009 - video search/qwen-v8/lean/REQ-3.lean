import ContractForge
open ContractForge

-- REQ-3: There will be a tick box to allow the user to choose to include torrent searching in the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  includeTorrentSearch : Bool
  deriving DecidableEq, Repr

structure Output where
  includeTorrentSearch : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.includeTorrentSearch = i.includeTorrentSearch

example : Spec.pre { includeTorrentSearch := true } ∧
          Spec.post { includeTorrentSearch := true }
                    { includeTorrentSearch := true } := by
  unfold Spec; decide
