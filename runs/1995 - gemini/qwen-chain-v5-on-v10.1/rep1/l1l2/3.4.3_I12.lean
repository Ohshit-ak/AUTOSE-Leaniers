import ContractForge
open ContractForge

-- 3.4.3/I12: On-line version control must be implemented. That is, the version control system must be available to recover/restore versions at all times.

-- L0 spec

structure Input where
  versions : List String
  deriving DecidableEq, Repr

structure Output where
  versions : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.versions = i.versions

example : Spec.pre { versions := ["v1", "v2", "v3"] } ∧
          Spec.post { versions := ["v1", "v2", "v3"] } { versions := ["v1", "v2", "v3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { versions := x.versions }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
