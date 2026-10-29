-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- checked: None

structure PlugInOption where
  name : String
  value : String

structure Input where
  plugIns : List PlugInOption

structure Output where
  plugIns : List PlugInOption

def Spec : Contract Input Output where
  pre input := true
  post input output := input.plugIns = output.plugIns ∧
                        input.plugIns.Pairwise (·.value ≤ ·.value)

example : Spec
:= by
  let input := { plugIns := #[PlugInOption.name "Option1" value "NewValue1", PlugInOption.name "Option2" value "NewValue2"] }
  let output := { plugIns := #[PlugInOption.name "Option1" value "NewValue1", PlugInOption.name "Option2" value "NewValue2"] }
  trivial
