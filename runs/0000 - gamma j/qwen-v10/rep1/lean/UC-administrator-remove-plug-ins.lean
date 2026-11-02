import ContractForge
open ContractForge

-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- compiles: True · rejects_bad_example: True · checked: True

structure PlugIn where
  name : String
  version : String
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  plugInName : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugInName ≠ ""
  post := fun i o => o.removed = true ∧
                     (∀ p ∈ i.plugIns, p.name ≠ i.plugInName → p ∈ o.plugIns) ∧
                     o.plugIns.length = i.plugIns.length - 1

example : Spec.pre { plugIns := [{ name := "plugin1", version := "1.0" },
                                  { name := "plugin2", version := "2.0" }],
                     plugInName := "plugin1" } ∧
          Spec.post { plugIns := [{ name := "plugin1", version := "1.0" },
                                  { name := "plugin2", version := "2.0" }],
                      plugInName := "plugin1" }
                    { plugIns := [{ name := "plugin2", version := "2.0" }],
                      removed := true } := by
  unfold Spec; decide
