import ContractForge
open ContractForge

-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.

-- L0 spec

structure PlugIn where
  name : String
  version : String
  deriving DecidableEq, Repr

structure Input where
  installedPlugIns : List PlugIn
  newPlugIn : PlugIn
  deriving DecidableEq, Repr

structure Output where
  installedPlugIns : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newPlugIn.name ≠ "" ∧ i.newPlugIn.version ≠ ""
  post := fun i o => o.installedPlugIns = i.installedPlugIns ++ [i.newPlugIn]

example : Spec.pre { installedPlugIns := [], newPlugIn := { name := "PluginX", version := "1.0" } } ∧
          Spec.post { installedPlugIns := [], newPlugIn := { name := "PluginX", version := "1.0" } }
                    { installedPlugIns := [{ name := "PluginX", version := "1.0" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { installedPlugIns := x.installedPlugIns ++ [x.newPlugIn] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
