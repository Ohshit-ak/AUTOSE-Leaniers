import ContractForge
open ContractForge

-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  installedPlugins : List String
  deriving DecidableEq, Repr

structure Output where
  installedPlugins : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.installedPlugins = i.installedPlugins ++ ["new-plug-in"]

example : Spec.pre { installedPlugins := ["plug-in1", "plug-in2"] } ∧
          Spec.post { installedPlugins := ["plug-in1", "plug-in2"] }
                    { installedPlugins := ["plug-in1", "plug-in2", "new-plug-in"] } := by
  unfold Spec; decide
