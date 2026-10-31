-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- checked: True

structure Input where
  installedPlugIns : List String
  deriving DecidableEq, Repr

structure Output where
  installedPlugIns : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.installedPlugIns = i.installedPlugIns ++ ["new-plug-in"]

example : Spec.pre { installedPlugIns := ["plug-in1", "plug-in2"] } ∧
          Spec.post { installedPlugIns := ["plug-in1", "plug-in2"] }
                    { installedPlugIns := ["plug-in1", "plug-in2", "new-plug-in"] } := by
  unfold Spec; decide
