import ContractForge
open ContractForge

-- 1.3/S4: It provides tools to help when navigating through search results which will save time and effort.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  page : Nat
  resultsPerPage : Nat
  totalResults : Nat
  deriving DecidableEq, Repr

structure Output where
  page : Nat
  resultsPerPage : Nat
  totalResults : Nat
  firstResult : Nat
  lastResult : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.resultsPerPage ∧ i.resultsPerPage ≤ i.totalResults
  post := fun i o => o.page = i.page ∧
                     o.resultsPerPage = i.resultsPerPage ∧
                     o.totalResults = i.totalResults ∧
                     o.firstResult = i.page * i.resultsPerPage - i.resultsPerPage + 1 ∧
                     o.lastResult = min (i.page * i.resultsPerPage) i.totalResults

example : Spec.pre { page := 1, resultsPerPage := 10, totalResults := 50 } ∧
          Spec.post { page := 1, resultsPerPage := 10, totalResults := 50 }
                    { page := 1, resultsPerPage := 10, totalResults := 50, firstResult := 1, lastResult := 10 } := by
  unfold Spec; decide
