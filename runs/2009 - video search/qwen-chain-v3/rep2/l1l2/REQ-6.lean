import ContractForge
open ContractForge

-- REQ-6: Results will be arranged in size/date/alphabetical order by clicking on the column headers.

-- L0 spec

structure Torrent where
  size   : Nat
  date   : Nat
  name   : String
  deriving DecidableEq, Repr

structure Input where
  torrents : List Torrent
  deriving DecidableEq, Repr

structure Output where
  torrents : List Torrent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => List.Pairwise (fun a b => a.size ≤ b.size) o.torrents ∧
                     List.Pairwise (fun a b => a.date ≤ b.date) o.torrents ∧
                     List.Pairwise (fun a b => a.name ≤ b.name) o.torrents ∧
                     List.Perm i.torrents o.torrents

example : Spec.pre { torrents := [{ size := 100, date := 20230101, name := "a" },
                                   { size := 200, date := 20230102, name := "b" }] } ∧
          Spec.post { torrents := [{ size := 100, date := 20230101, name := "a" },
                                   { size := 200, date := 20230102, name := "b" }] }
                    { torrents := [{ size := 100, date := 20230101, name := "a" },
                                   { size := 200, date := 20230102, name := "b" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  torrents : List Torrent
  deriving DecidableEq, Repr

def SortBySizeContract : Contract Input Mid where
  pre  := fun i => True
  post := fun i m => List.Pairwise (fun a b => a.size ≤ b.size) m.torrents ∧
                     List.Perm i.torrents m.torrents

def SortByDateNameContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => List.Pairwise (fun a b => a.date ≤ b.date) o.torrents ∧
                     List.Pairwise (fun a b => a.name ≤ b.name) o.torrents ∧
                     List.Perm m.torrents o.torrents
