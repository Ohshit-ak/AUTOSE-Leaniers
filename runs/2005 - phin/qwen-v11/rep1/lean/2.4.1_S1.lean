import ContractForge
open ContractForge

-- 2.4.1/S1: Systems supporting OM should allow for analytical searches based upon multiple criteria.
-- compiles: True · rejects_bad_example: True · checked: True

structure DataPoint where
  name   : String
  value  : Nat
  source : String
  deriving DecidableEq, Repr

structure Input where
  criteria : List String
  data     : List DataPoint
  deriving DecidableEq, Repr

structure Output where
  results : List DataPoint
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o =>
    (∀ dp ∈ o.results, ∃ c ∈ i.criteria, dp.name = c) ∧
    (o.results.length ≤ 100 → ∀ dp ∈ i.data, (∃ c ∈ i.criteria, dp.name = c) → dp ∈ o.results)

example : Spec.pre { criteria := ["cases", "deaths"], data := [{ name := "cases", value := 500, source := "health" },
                                                              { name := "deaths", value := 100, source := "health" },
                                                              { name := "recovered", value := 300, source := "health" }] } ∧
          Spec.post { criteria := ["cases", "deaths"], data := [{ name := "cases", value := 500, source := "health" },
                                                                { name := "deaths", value := 100, source := "health" },
                                                                { name := "recovered", value := 300, source := "health" }] }
                    { results := [{ name := "cases", value := 500, source := "health" },
                                  { name := "deaths", value := 100, source := "health" }] } := by
  unfold Spec; decide
