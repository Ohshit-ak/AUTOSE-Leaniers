import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: None · checked: False

structure PlugInOption where
  name   : String
  value  : String
  enabled : Bool
  deriving DecidableEq, Repr

structure Input where
  plugInName : String
  options    : List PlugInOption
  newOptions : List PlugInOption
  deriving DecidableEq, Repr

structure Output where
  plugInName : String
  options    : List PlugInOption
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugInName ≠ "" ∧ i.options.Nodup ∧ i.newOptions.Nodup
  post := fun i o =>
    (o.plugInName = i.plugInName) ∧
    (o.options.length = i.options.length) ∧
    (∀ opt ∈ o.options, ∃ newOpt ∈ i.newOptions, newOpt.name = opt.name ∧ newOpt.value = opt.value ∧ newOpt.enabled = opt.enabled)

example : Spec.pre { plugInName := "plugin1", options := [{ name := "opt1", value := "on", enabled := true },
                                                           { name := "opt2", value := "off", enabled := false }],
                     newOptions := [{ name := "opt1", value := "off", enabled := false },
                                    { name := "opt2", value := "on", enabled := true }] } ∧
          Spec.post { plugInName := "plugin1", options := [{ name := "opt1", value := "off", enabled := false },
                                                            { name := "opt2", value := "on", enabled := true }],
                      newOptions := [{ name := "opt1", value := "off", enabled := false },
                                     { name := "opt2", value := "on", enabled := true }] }
                    { plugInName := "plugin1", options := [{ name := "opt1", value := "off", enabled := false },
                                                           { name := "opt2", value := "on", enabled := true }] } := by
  unfold Spec; decide
