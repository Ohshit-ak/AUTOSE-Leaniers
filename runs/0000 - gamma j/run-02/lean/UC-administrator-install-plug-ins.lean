-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- checked: True

structure Input where
  installedPlugins : List String
  success          : Bool
  deriving DecidableEq, Repr

structure Output where
  installedPlugins : List String
  success          : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.installedPlugins.Nodup ∧ i.success
  post := fun i o => o.success = true ∧
                     o.installedPlugins = i.installedPlugins ++ [ "new-plugin" ] ∧
                     o.installedPlugins.Nodup

example : Spec.pre { installedPlugins := ["plugin1", "plugin2"], success := true } ∧
          Spec.post { installedPlugins := ["plugin1", "plugin2"], success := true }
                    { installedPlugins := ["plugin1", "plugin2", "new-plugin"], success := true } := by
  unfold Spec; decide
