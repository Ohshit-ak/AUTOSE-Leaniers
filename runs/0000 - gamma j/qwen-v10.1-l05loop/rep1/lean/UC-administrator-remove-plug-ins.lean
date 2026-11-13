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
                     (∀ p ∈ i.plugIns, p.name ≠ i.plugInName) ∧
                     o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.plugInName)

example : Spec.pre { plugIns := [], plugInName := "plugin1" } ∧ Spec.post { plugIns := [], plugInName := "plugin1" } { plugIns := [], removed := true } := by
  unfold Spec; decide
