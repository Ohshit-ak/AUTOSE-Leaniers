import ContractForge
open ContractForge

-- REQ-6: Results will be arranged in size/date/alphabetical order by clicking on the column headers.
-- compiles: True · rejects_bad_example: None · checked: False

structure Torrent where
  size   : Nat
  date   : Nat
  name   : String
  selected : String
  deriving DecidableEq, Repr

structure Input where
  torrents : List Torrent
  selected : String
  deriving DecidableEq, Repr

structure Output where
  torrents : List Torrent
  deriving DecidableEq, Repr

-- an item is in the right order if its selected field is in the right order
def InOrder (i : Input) (it : Torrent) : Bool :=
  it.selected = i.selected

def Spec : Contract Input Output where
  pre  := fun i => i.torrents.Nodup
  post := fun i o =>
    List.Pairwise (fun a b => InOrder i a → a.selected ≤ b.selected) o.torrents

example : Spec.pre { torrents := [{ size := 100, date := 20230101, name := "file1", selected := "name" },
                                   { size := 200, date := 20230102, name := "file2", selected := "name" }],
                     selected := "name" } ∧
          Spec.post { torrents := [{ size := 100, date := 20230101, name := "file1", selected := "name" },
                                   { size := 200, date := 20230102, name := "file2", selected := "name" }],
                      selected := "name" }
                    { torrents := [{ name := "file1", size := 100, date := 20230101, selected := "name" },
                                   { name := "file2", size := 200, date := 20230102, selected := "name" }] } := by
  unfold Spec; decide
