import ContractForge
open ContractForge

-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- compiles: True · rejects_bad_example: None · checked: True

structure PlugIn where
  name : String
  deriving DecidableEq, Repr

structure Input where
  plugins : List PlugIn
  deriving DecidableEq, Repr

structure Output where
  plugins : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.plugins = i.plugins ++ [{ name := "newPlugIn" }]

example : Spec.pre { plugins := [] } ∧
          Spec.post { plugins := [] }
                    { plugins := [{ name := "newPlugIn" }] } := by
  unfold Spec; decide
