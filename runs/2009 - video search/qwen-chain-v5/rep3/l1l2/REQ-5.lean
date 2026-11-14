import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."

-- L0 spec

structure Input where
  query          : String
  results        : List String
  deriving DecidableEq, Repr

structure Output where
  message        : String
  results        : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (o.results = [] → o.message = "No results were found for this search.")

example : Spec.pre { query := "cats", results := [] } ∧
          Spec.post { query := "cats", results := [] }
                    { message := "No results were found for this search.", results := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { message := if x.results = [] then "No results were found for this search." else "", results := x.results }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
