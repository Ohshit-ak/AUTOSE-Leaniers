import ContractForge
open ContractForge

-- 1.3/S1: This Video Searching software will be a system that uses an active internet connection to search multiple websites for streaming videos or torrents.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query  : String
  websites : List String
  deriving DecidableEq, Repr

structure Output where
  videos  : List String
  torrents : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ "" ∧ i.websites.Nodup
  post := fun i o => o.videos.Nodup ∧ o.torrents.Nodup ∧
                     (o.videos = i.websites.map (fun w => w ++ "/video?q=" ++ i.query)) ∧
                     (o.torrents = i.websites.map (fun w => w ++ "/torrent?q=" ++ i.query))

example : Spec.pre { query := "example", websites := ["website1.com", "website2.com"] } ∧
          Spec.post { query := "example", websites := ["website1.com", "website2.com"] }
                    { videos := ["website1.com/video?q=example", "website2.com/video?q=example"],
                      torrents := ["website1.com/torrent?q=example", "website2.com/torrent?q=example"] } := by
  unfold Spec; decide
