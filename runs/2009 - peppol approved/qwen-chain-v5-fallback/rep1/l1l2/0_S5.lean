import ContractForge
open ContractForge

-- 0/S5: The following description responds to these comments and criticism by arguing how and where revisions and updates of the work presented in this deliverable will be implemented in subsequent results of WP 2.

-- L0 spec

structure Input where
  version : Nat
  changes : List String
  deriving DecidableEq, Repr

structure Output where
  version : Nat
  changes : List String
  deriving DecidableEq, Repr

-- IMPL: Versioning and Change Log

def Spec : Contract Input Output where
  pre  := fun i => i.version > 0
  post := fun i o => o.version = i.version + 1 ∧
                     o.changes = i.changes

example : Spec.pre { version := 1, changes := ["Fix typos", "Add section on methodology"] } ∧
          Spec.post { version := 1, changes := ["Fix typos", "Add section on methodology"] }
                    { version := 2, changes := ["Fix typos", "Add section on methodology"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { version := x.version + 1,
    changes := x.changes }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
