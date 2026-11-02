import ContractForge
open ContractForge

-- REQ-6#2: Query to video link sites will retrieve the show's name, episode name and a link to the webpage itself.
-- compiles: False · rejects_bad_example: None · checked: False

structure VideoInfo where
  showName : String
  episodeName : String
  link : String
  deriving DecidableEq, Repr

structure Input where
  query : String
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  results : List VideoInfo
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (∀ it ∈ o.results, it.showName ≠ "" ∧ it.episodeName ≠ "" ∧ it.link ≠ "")
    ∧ (∀ it ∈ o.results, it.showName = it.link.splitOn("/").getLast)
    ∧ (∀ it ∈ o.results, it.episodeName = it.link.splitOn("/").getPenultimate)

example : Spec.pre { query := "Stranger Things", sites := ["example.com"] } ∧
          Spec.post { query := "Stranger Things", sites := ["example.com"] }
                    { results := [{ showName := "Stranger Things", episodeName := "Chapter 1", link := "example.com/Stranger-Things/Chapter-1" }] } := by
  unfold Spec; decide
