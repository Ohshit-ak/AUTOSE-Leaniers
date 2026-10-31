import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: None · checked: True

structure PlugInOption where
  name : String
  value : String
  deriving DecidableEq, Repr

structure Input where
  options : List PlugInOption
  deriving DecidableEq, Repr

structure Output where
  options : List PlugInOption
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.options.length > 0
  post := fun i o => o.confirmed = true ∧
                     o.options = i.options.map (fun opt => { name := opt.name, value := "new_value" })

example : Spec.pre { options := [{ name := "opt1", value := "old_value1" },
                                  { name := "opt2", value := "old_value2" }] } ∧
          Spec.post { options := [{ name := "opt1", value := "old_value1" },
                                   { name := "opt2", value := "old_value2" }] }
                    { confirmed := true, options := [{ name := "opt1", value := "new_value" },
                                                     { name := "opt2", value := "new_value" }] } := by
  unfold Spec; decide
