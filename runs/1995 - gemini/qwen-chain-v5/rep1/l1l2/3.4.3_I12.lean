import ContractForge
open ContractForge

-- 3.4.3/I12: On-line version control must be implemented. That is, the version control system must be available to recover/restore versions at all times.

-- L0 spec

structure Input where
  version : Nat
  versionHistory : List Nat
  deriving DecidableEq, Repr

structure Output where
  version : Nat
  versionHistory : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.versionHistory.Nodup
  post := fun i o => o.version = i.version ∧
                     o.versionHistory = i.versionHistory ∧
                     (o.version = i.version → o.versionHistory = i.versionHistory)

example : Spec.pre { version := 3, versionHistory := [1, 2, 3] } ∧
          Spec.post { version := 3, versionHistory := [1, 2, 3] }
                    { version := 3, versionHistory := [1, 2, 3] } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { version := x.version,
    versionHistory := x.versionHistory }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
