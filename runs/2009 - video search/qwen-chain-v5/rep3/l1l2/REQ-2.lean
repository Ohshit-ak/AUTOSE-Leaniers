import ContractForge
open ContractForge

-- REQ-2: Database of torrent sites can be updated via the internet.

-- L0 spec

structure Input where
  sites : List String
  updateFailed : Bool
  deriving DecidableEq, Repr

structure Output where
  updatedSites : List String
  deriving DecidableEq, Repr

-- IMPL: The torrent sites database is updated via the internet.

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0 ∧ ¬i.updateFailed
  post := fun i o => o.updatedSites = i.sites ↔ ¬i.updateFailed

example : Spec.pre { sites := ["site1", "site2"], updateFailed := false } ∧
          Spec.post { sites := ["site1", "site2"], updateFailed := false } { updatedSites := ["site1", "site2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { updatedSites := if ¬x.updateFailed then x.sites else [] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
