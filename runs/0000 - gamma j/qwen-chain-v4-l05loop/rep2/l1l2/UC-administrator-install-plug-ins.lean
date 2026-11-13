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
  post := fun i o => o.installedPlugIns = i.installedPlugIns ++ [i.newPlugIn] ∧
                     o.installedPlugIns.Nodup

example : Spec.pre { installedPlugIns := [{ name := "plugin1", version := "1.0" }],
                     newPlugIn := { name := "plugin2", version := "2.0" } } ∧
          Spec.post { installedPlugIns := [{ name := "plugin1", version := "1.0" }],
                      newPlugIn := { name := "plugin2", version := "2.0" } }
                    { installedPlugIns := [{ name := "plugin1", version := "1.0" },
                                           { name := "plugin2", version := "2.0" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { installedPlugIns := x.installedPlugIns ++ [x.newPlugIn] }
