import ContractForge
open ContractForge

-- REQ-2#2: Database of video hosting and video linking sites can be updated via the internet.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  siteURL : String
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  deriving DecidableEq, Repr

-- IMPL: HTTP request to update the database

def Spec : Contract Input Output where
  pre  := fun i => i.siteURL ≠ ""
  post := fun i o => o.updated = true

example : Spec.pre { siteURL := "https://example.com" } ∧
          Spec.post { siteURL := "https://example.com" }
                    { updated := true } := by
  unfold Spec; decide
