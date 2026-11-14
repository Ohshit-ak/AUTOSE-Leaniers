import ContractForge
open ContractForge

-- REQ-1#2: Streaming search will share the same search bar with the torrent search.

-- L0 spec

structure Input where
  query          : String
  torrentResults : List String
  deriving DecidableEq, Repr

structure Output where
  videoResults  : List String
  message       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No video results were found." ↔ o.videoResults = []) ∧
    (∀ v ∈ o.videoResults, v ∈ i.torrentResults ∧ v.contains i.query)

example : Spec.pre { query := "cats", torrentResults := ["cats.mp4", "dogs.mp4", "cats.webm"] } ∧ Spec.post { query := "cats", torrentResults := ["cats.mp4", "dogs.mp4", "cats.webm"] } { videoResults := [], message := "No video results were found." } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  videoResults : List String
  deriving DecidableEq, Repr

def FindVideoResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => ∀ v ∈ m.videoResults, v ∈ i.torrentResults ∧ v.contains i.query

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.message = "No video results were found." ↔ o.videoResults = []) ∧
                     (∀ v ∈ o.videoResults, v ∈ m.videoResults)

theorem po1 : Contract.Compatible FindVideoResultsContract FormatMessageContract := by
  discharge_po1 [FindVideoResultsContract, FormatMessageContract, Spec]

theorem po2 : Contract.Refines (FindVideoResultsContract.seq FormatMessageContract) Spec := by
  discharge_po2 [FindVideoResultsContract, FormatMessageContract, Spec]

-- L2 FindVideoResultsContract (success=True)

def FindVideoResultsContractImpl (x : Input) : Mid :=
  { videoResults := x.torrentResults.filter (fun v => decide (v ∈ x.torrentResults ∧ v.contains x.query)) }

theorem FindVideoResultsContractImpl_ok : FindVideoResultsContract.Satisfies FindVideoResultsContractImpl := by
  discharge_po3 [FindVideoResultsContract, FindVideoResultsContractImpl]

-- L2 FormatMessageContract (success=True)

def FormatMessageContractImpl (x : Mid) : Output :=
  { videoResults := x.videoResults,
    message := if x.videoResults = [] then "No video results were found." else "" }

theorem FormatMessageContractImpl_ok : FormatMessageContract.Satisfies FormatMessageContractImpl := by
  discharge_po3 [FormatMessageContract, FormatMessageContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FormatMessageContractImpl ∘ FindVideoResultsContractImpl) :=
  Contract.system_sound po1 po2 FindVideoResultsContractImpl_ok FormatMessageContractImpl_ok
