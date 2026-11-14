import ContractForge
open ContractForge

-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- compiles: False · rejects_bad_example: None · checked: False

structure PlugIn where
  name : String
  version : String
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  plugInName : String
  version : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugInName ≠ "" ∧ i.version ≠ ""
  post := fun i o => o.plugIns.length = i.plugIns.length - 1 ∧
                     ∃ p ∈ o.plugIns, p.name = i.plugInName ∧ p.version = i.version

example : Spec.pre { plugIns := [{ name := "plugin1", version := "1.0" },
                                  { name := "plugin2", version := "2.0" }],
                     plugInName := "plugin1", version := "1.0" } ∧
          Spec.post { plugIns := [{ name := "plugin1", version := "1.0" },
                                  { name := "plugin2", version := "2.0" }],
                      plugInName := "plugin1", version := "1.0" }
                    { plugIns := [{ name := "plugin2", version := "2.0" }] } := by
  unfold Spec; decide
