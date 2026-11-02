import ContractForge
open ContractForge

-- REQ-4: Query will retrieve the no. of seed and peers, size of the file, date posted and a link to the webpage itself.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  seedCount : Nat
  peerCount : Nat
  fileSize  : Nat
  datePosted : String
  link : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.seedCount ≥ 0 ∧ o.peerCount ≥ 0 ∧ o.fileSize ≥ 0 ∧
                     o.datePosted ≠ "" ∧ o.link ≠ ""

example : Spec.pre { query := "example query" } ∧
          Spec.post { query := "example query" }
                    { seedCount := 5, peerCount := 10, fileSize := 12345678, datePosted := "2023-10-01", link := "http://example.com" } := by
  unfold Spec; decide
