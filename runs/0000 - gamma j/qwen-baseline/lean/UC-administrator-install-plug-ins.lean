-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- checked: True

structure Input where
  currentPlugIns : List String

structure Output where
  installedPlugIns : List String

def Spec : Contract Input Output where
  pre  := fun i => i.currentPlugIns.length < 10
  post := fun i o => o.installedPlugIns = i.currentPlugIns ++ ["newPlugIn"]

example : Spec.pre ⟨["plugIn1", "plugIn2"]⟩ ∧ Spec.post ⟨["plugIn1", "plugIn2"]⟩ ⟨["plugIn1", "plugIn2", "newPlugIn"]⟩ := by
  simp [Spec]
