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

-- Decompose the spec into two components

def InstallPreContract : Contract Input Input where
  pre  := fun i => i.newPlugIn.name ≠ "" ∧ i.newPlugIn.version ≠ ""
  post := fun i i' => i' = i

def InstallPostContract : Contract Input Output where
  pre  := fun i => i.newPlugIn.name ≠ "" ∧ i.newPlugIn.version ≠ ""
  post := fun i o => o.installedPlugIns = i.installedPlugIns ++ [i.newPlugIn]

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_InstallPre : Contract.Compatible InstallPreContract Spec := by
  intro i i' h
  simp [InstallPreContract.post, Spec.post] at h
  simp [h]

theorem PO1_InstallPost : Contract.Compatible InstallPostContract InstallPreContract := by
  intro i i' h
  simp [InstallPostContract.post, InstallPreContract.post] at h
  simp [h]

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (InstallPreContract.seq InstallPostContract) Spec := by
  intro i o h
  simp [InstallPreContract.post, InstallPostContract.post, Spec.post] at h
  simp [h]

-- Discharge the proof obligations
discharge_po