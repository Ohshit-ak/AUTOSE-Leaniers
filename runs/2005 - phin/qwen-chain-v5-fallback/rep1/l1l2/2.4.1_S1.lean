import ContractForge
open ContractForge

-- 2.4.1/S1: Systems supporting OM should allow for analytical searches based upon multiple criteria.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { results := x.data.filter (fun dp => decide (∃ c ∈ x.criteria, dp.name = c)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
