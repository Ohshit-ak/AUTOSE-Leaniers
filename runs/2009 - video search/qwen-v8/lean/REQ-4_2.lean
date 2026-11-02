import ContractForge
open ContractForge

-- REQ-4#2: There will be a tick box to allow the user to choose to include video link searching in the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  includeLinks : Bool
  deriving DecidableEq, Repr

structure Output where
  includeLinks : Bool
  foundLinks   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.includeLinks = i.includeLinks ∧
                     (o.foundLinks ↔ i.includeLinks)

example : Spec.pre { includeLinks := true } ∧
          Spec.post { includeLinks := true }
                    { includeLinks := true, foundLinks := true } := by
  unfold Spec; decide
