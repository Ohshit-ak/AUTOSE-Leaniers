import ContractForge
open ContractForge

-- 3.2.5/S3: Reconfiguration procedures must exist, to change the observing environment.

-- L0 spec

structure Input where
  config : String
  changes : List String
  deriving DecidableEq, Repr

structure Output where
  config : String
  applied : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.config ≠ "" ∧ i.changes ≠ []
  post := fun i o => o.applied = true ↔
    (∀ c ∈ i.changes, c = i.config) ∧
    o.config = i.config ∧
    o.applied = (i.changes.length > 0)

example : Spec.pre { config := "env1", changes := ["env1"] } ∧
          Spec.post { config := "env1", changes := ["env1"] }
                    { applied := true, config := "env1" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { config := x.config, applied := (∀ c ∈ x.changes, c = x.config) ∧ (x.changes.length > 0) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
