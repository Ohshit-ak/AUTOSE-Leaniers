import ContractForge
open ContractForge

-- REQ-6: Results will be arranged in size/date/alphabetical order by clicking on the column headers.
-- compiles: False · rejects_bad_example: None · checked: False

structure Torrent where
  size   : Nat
  date   : Nat
  name   : String
  deriving DecidableEq, Repr

structure Input where
  torrents : List Torrent
  selected : String
  deriving DecidableEq, Repr

structure Output where
  torrents : List Torrent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => List.Pairwise (fun a b => a.selected = i.selected ∧ (a.size ≤ b.size ∨ (a.size = b.size ∧ a.date ≤ b.date ∨ (a.size = b.size ∧ a.date = b.date ∧ a.name ≤ b.name)))) o.torrents

example : Spec.pre { torrents := [{ size := 10, date := 20230101, name := "file1" },
                                   { size := 10, date := 20230102, name := "file2" },
                                   { size := 15, date := 20230101, name := "file3" }],
                    selected := "size" } ∧
          Spec.post { torrents := [{ size := 10, date := 20230101, name := "file1" },
                                    { size := 10, date := 20230102, name := "file2" },
                                    { size := 15, date := 20230101, name := "file3" }],
                      selected := "size" }
                    { torrents := [{ size := 10, date := 20230101, name := "file1" },
                                   { size := 10, date := 20230102, name := "file2" },
                                   { size := 15, date := 20230101, name := "file3" }] } := by
  unfold Spec; decide
