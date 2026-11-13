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

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { torrents := x.torrents }
