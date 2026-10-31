import ContractForge
open ContractForge

-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- compiles: True · rejects_bad_example: True · checked: True

structure PlugIn where
  name : String
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  name    : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.any (·.name = i.name)
  post := fun i o => o.removed = true ∧
                     o.plugIns = i.plugIns.filter (·.name ≠ i.name)

example : Spec.pre { plugIns := [{ name := "plugin1" }, { name := "plugin2" }],
                     name := "plugin1" } ∧
          Spec.post { plugIns := [{ name := "plugin1" }, { name := "plugin2" }],
                      name := "plugin1" }
                    { plugIns := [{ name := "plugin2" }], removed := true } := by
  unfold Spec; decide
