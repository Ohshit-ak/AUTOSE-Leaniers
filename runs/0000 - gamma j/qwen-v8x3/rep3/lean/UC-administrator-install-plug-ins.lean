import ContractForge
open ContractForge

-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  plugins : List String
  installed : Bool
  deriving DecidableEq, Repr

structure Output where
  plugins : List String
  installed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugins.length < 10
  post := fun i o => o.installed = true ∧
                     o.plugins = i.plugins ++ ["new-plug-in"]

example : Spec.pre { plugins := ["plug-in1", "plug-in2"], installed := false } ∧
          Spec.post { plugins := ["plug-in1", "plug-in2"], installed := false }
                    { plugins := ["plug-in1", "plug-in2", "new-plug-in"], installed := true } := by
  unfold Spec; decide
