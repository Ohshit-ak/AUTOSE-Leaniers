import ContractForge
open ContractForge

-- REQ-6#2: Query to video link sites will retrieve the show's name, episode name and a link to the webpage itself.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  showName   : String
  episodeName: String
  link       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => o.showName ≠ "" ∧ o.episodeName ≠ "" ∧ o.link ≠ ""

example : Spec.pre { query := "Stranger Things Season 2 Episode 5" } ∧
          Spec.post { query := "Stranger Things Season 2 Episode 5" }
                    { showName := "Stranger Things", episodeName := "Chapter 5: The Upside Down", link := "https://example.com/episode/5" } := by
  unfold Spec; decide
