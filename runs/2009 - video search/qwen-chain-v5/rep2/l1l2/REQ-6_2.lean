import ContractForge
open ContractForge

-- REQ-6#2: Query to video link sites will retrieve the show's name, episode name and a link to the webpage itself.

-- L0 spec

structure VideoLinkSite where
  showName   : String
  episodeName: String
  link       : String
  deriving DecidableEq, Repr

structure Input where
  query          : String
  sites          : List VideoLinkSite
  deriving DecidableEq, Repr

structure Output where
  results : List VideoLinkSite
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.sites ∧ it.showName ≠ "" ∧ it.episodeName ≠ "" ∧ it.link ≠ "") ∧
    (o.results.length ≤ 100 → ∀ it ∈ i.sites, it.showName ≠ "" ∧ it.episodeName ≠ "" ∧ it.link ≠ "" → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    (∀ it ∈ o.results, it.showName = i.query)

example : Spec.pre { query := "Stranger Things", sites := [{ showName := "Stranger Things", episodeName := "The Dark Hole", link := "https://example.com/Stranger_Things_The_Dark_Hole" }] } ∧
          Spec.post { query := "Stranger Things", sites := [{ showName := "Stranger Things", episodeName := "The Dark Hole", link := "https://example.com/Stranger_Things_The_Dark_Hole" }] }
                    { results := [{ showName := "Stranger Things", episodeName := "The Dark Hole", link := "https://example.com/Stranger_Things_The_Dark_Hole" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := (x.sites.filter (fun it => it.showName = x.query ∧ it.episodeName ≠ "" ∧ it.link ≠ "")).take 100 }
