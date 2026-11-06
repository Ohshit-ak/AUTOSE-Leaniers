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

-- L1 architect (success=False)

structure Mid where
  name : String
  version : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.newPlugIn.name ≠ "" ∧ i.newPlugIn.version ≠ ""
  post := fun i m => m.name = i.newPlugIn.name ∧ m.version = i.newPlugIn.version

def InstallContract : Contract Mid Output where
  pre  := fun m => m.name ≠ "" ∧ m.version ≠ ""
  post := fun m o => o.installedPlugIns = m :: m :: [] -- Ensure the plug-in is installed

theorem po1 : Contract.Compatible ValidateContract InstallContract := by
  unfold Contract.Compatible ValidateContract InstallContract
  intro i m _ h
  exact h.2

theorem po2 : Contract.Refines (ValidateContract.seq InstallContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract InstallContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hn, hv, _⟩, ho⟩
  simp only at *
  rw [ho, hn, hv]