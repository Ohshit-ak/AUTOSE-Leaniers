import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.

-- L0 spec

structure Patch where
  version : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i o => o.webStoreVersion = i.webStoreVersion ∧
                     o.success = true ∧
                     o.patches = i.patches

example : Spec.pre { webStoreVersion := "1.0.0", patches := [], success := true } ∧
          Spec.post { webStoreVersion := "1.0.0", patches := [], success := true }
                    { webStoreVersion := "1.0.0", patches := [], success := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { webStoreVersion := x.webStoreVersion, patches := x.patches, success := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
