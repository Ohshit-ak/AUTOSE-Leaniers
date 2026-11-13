import ContractForge
open ContractForge

-- 3.1.3/R1: REQ-1: KeePass must be downloaded and installed

-- L0 spec

structure Input where
  version : String
  downloaded : Bool
  deriving DecidableEq, Repr

structure Output where
  installed : Bool
  versionInstalled : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.version ≠ "" ∧ i.downloaded
  post := fun i o => (o.installed = true ↔ i.downloaded) ∧
                     (o.installed = false → o.versionInstalled = "") ∧
                     (o.installed = true → o.versionInstalled = i.version)

example : Spec.pre { version := "2.48", downloaded := true } ∧ Spec.post { version := "2.48", downloaded := true } { installed := true, versionInstalled := "2.48" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { installed := x.downloaded, versionInstalled := if x.downloaded then x.version else "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
