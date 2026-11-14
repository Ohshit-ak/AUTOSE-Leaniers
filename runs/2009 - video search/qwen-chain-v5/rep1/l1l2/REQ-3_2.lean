import ContractForge
open ContractForge

-- REQ-3#2: There will be a tick box to allow the user to choose to include video host searching in the search.

-- L0 spec

structure Input where
  includeHost : Bool
  query       : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  length  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeHost = false) ∧
    (o.results.length > 0 → i.includeHost = true)

example : Spec.pre { includeHost := false, query := "example" } ∧
          Spec.post { includeHost := false, query := "example" }
                    { results := [], length := 0 } := by
  unfold Spec; decide

example : Spec.pre { includeHost := true, query := "example" } ∧
          Spec.post { includeHost := true, query := "example" }
                    { results := ["host1", "host2"], length := 2 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { results := if x.includeHost then ["host1"] else [],
    length := if x.includeHost then 1 else 0 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
