import ContractForge
open ContractForge

-- REQ-4#2: There will be a tick box to allow the user to choose to include video link searching in the search.

-- L0 spec

structure Input where
  includeVideoLinks : Bool
  query             : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeVideoLinks = false) ∧
    (o.results.length > 0 → i.includeVideoLinks = true)

example : Spec.pre { includeVideoLinks := true, query := "cats" } ∧
          Spec.post { includeVideoLinks := true, query := "cats" }
                    { results := ["video1", "video2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { results := if x.includeVideoLinks then ["result1", "result2"] else [] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
