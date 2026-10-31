-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- checked: False

structure Input where
  installedPlugIns : List String
  deriving DecidableEq, Repr

structure Output where
  installedPlugIns : List String
  newPlugIn        : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.installedPlugIns.Nodup
  post := fun i o => o.installedPlugIns = i.installedPlugIns ++ [o.newPlugIn] ∧
                     o.newPlugIn ∉ i.installedPlugIns

example : Spec.pre { installedPlugIns := ["PlugIn1", "PlugIn2"] } ∧
          Spec.post { installedPlugIns := ["PlugIn1", "PlugIn2"], newPlugIn := "PlugIn3" }
                    { installedPlugIns := ["PlugIn1", "PlugIn2", "PlugIn3"], newPlugIn := "PlugIn3" } := by
  unfold Spec; decide
