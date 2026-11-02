import ContractForge
open ContractForge

-- REQ-5#2: Query to video hosting sites will retrieve full video name, length, date posted and a link to the video itself.
-- compiles: True · rejects_bad_example: True · checked: True

structure Video where
  name   : String
  length : Nat
  date   : String
  link   : String
  deriving DecidableEq, Repr

structure Input where
  query          : String
  sites          : List String
  deriving DecidableEq, Repr

structure Output where
  results : List Video
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (∀ it ∈ o.results, it.name ≠ "" ∧ it.length ≠ 0 ∧ it.date ≠ "" ∧ it.link ≠ "") ∧
    (∀ it ∈ o.results, it.name = i.query) ∧
    (o.results.length ≤ 100) ∧
    List.Perm (i.sites.map (fun s => { name := "", length := 0, date := "", link := s })) o.results

example : Spec.pre { query := "cats", sites := [] } ∧ Spec.post { query := "cats", sites := [] } { results := [] } := by
  unfold Spec; decide
