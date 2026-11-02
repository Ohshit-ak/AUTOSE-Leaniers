import ContractForge
open ContractForge

-- REQ-3#2: There will be a tick box to allow the user to choose to include video host searching in the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  includeHostSearch : Bool
  deriving DecidableEq, Repr

structure Output where
  includeHostSearch : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.includeHostSearch = i.includeHostSearch

example : Spec.pre { includeHostSearch := true } ∧
          Spec.post { includeHostSearch := true } { includeHostSearch := true } := by
  unfold Spec; decide
