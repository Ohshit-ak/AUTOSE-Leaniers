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
  pre  := fun i => i.query ≠ "" ∧ i.sites.Nodup
  post := fun i o =>
    (∀ it ∈ o.results, it.showName ≠ "" ∧ it.episodeName ≠ "" ∧ it.link ≠ "")
    ∧
    (∀ it ∈ o.results, it.showName = it.link.splitOn('/').last)
    ∧
    (∀ it ∈ o.results, it.episodeName = it.link.splitOn('/').get?2)
    ∧
    (∀ it ∈ o.results, it.link ∈ i.sites)

example : Spec.pre { query := "Game of Thrones", sites := ["site1.com", "site2.com"] } ∧
          Spec.post { query := "Game of Thrones", sites := ["site1.com", "site2.com"] }
                    { results := [{ showName := "Game of Thrones", episodeName := "Winter Is Coming", link := "site1.com/game-of-thrones/1" },
                                  { showName := "Game of Thrones", episodeName := "Winter Is Coming", link := "site2.com/game-of-thrones/1" }] } := by
  unfold Spec; decide
