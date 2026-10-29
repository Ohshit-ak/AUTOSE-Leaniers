-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- checked: None

structure PlugIn where
  name : String

structure ApplicationState where
  plugIns : List PlugIn

structure Input where
  plugIns : List PlugIn
  plugInToRemove : PlugIn

structure Output where
  updatedPlugIns : List PlugIn

def Spec : Contract Input Output where
  pre input := 
    input.plugInToRemove ∈ input.plugIns
  post input output := 
    List.Perm input.plugIns output.updatedPlugIns ∧
    output.updatedPlugIns = List.filter (· ≠ input.plugInToRemove) input.plugIns

example : Spec
where
  input := 
    { plugIns := #[PlugIn.name "Plugin1", PlugIn.name "Plugin2", PlugIn.name "Plugin3"],
      plugInToRemove := PlugIn.name "Plugin2" }
  output := 
    { updatedPlugIns := #[PlugIn.name "Plugin1", PlugIn.name "Plugin3"] }
