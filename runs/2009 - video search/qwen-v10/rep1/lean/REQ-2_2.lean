import ContractForge
open ContractForge

-- REQ-2#2: Database of video hosting and video linking sites can be updated via the internet.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  deriving DecidableEq, Repr

-- IMPL: Database update via the internet

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.updated = true

example : Spec.pre { sites := ["site1", "site2"] } ∧
          Spec.post { sites := ["site1", "site2"] } { updated := true } := by
  unfold Spec; decide
