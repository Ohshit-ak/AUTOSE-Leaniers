import ContractForge
open ContractForge

-- REQ-5#2: Query to video hosting sites will retrieve full video name, length, date posted and a link to the video itself.

-- L0 spec

structure Video where
  name     : String
  length   : Nat
  date     : String
  link     : String
  deriving DecidableEq, Repr

structure Input where
  query          : String
  sites          : List String
  videoResults   : List Video
  deriving DecidableEq, Repr

structure Output where
  results : List Video
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.videoResults ∧
      it.name ≠ "" ∧
      0 < it.length ∧
      it.date ≠ "" ∧
      it.link ≠ "") ∧
    (o.results = [] ↔ i.videoResults = [])

example : Spec.pre { query := "cat", sites := ["site1.com", "site2.com"],
                     videoResults := [{ name := "Cats", length := 5, date := "2023-10-01", link := "https://site1.com/video1" },
                                      { name := "Cats", length := 10, date := "2023-10-02", link := "https://site2.com/video2" }] } ∧
          Spec.post { query := "cat", sites := ["site1.com", "site2.com"],
                      videoResults := [{ name := "Cats", length := 5, date := "2023-10-01", link := "https://site1.com/video1" },
                                      { name := "Cats", length := 10, date := "2023-10-02", link := "https://site2.com/video2" }] }
                    { results := [{ name := "Cats", length := 5, date := "2023-10-01", link := "https://site1.com/video1" },
                                  { name := "Cats", length := 10, date := "2023-10-02", link := "https://site2.com/video2" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := x.videoResults.filter (fun it => it.name ≠ "" ∧
      0 < it.length ∧
      it.date ≠ "" ∧
      it.link ≠ "") }
