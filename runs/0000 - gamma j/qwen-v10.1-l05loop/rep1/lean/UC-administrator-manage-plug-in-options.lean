import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: None · checked: False

structure PlugInOption where
  name   : String
  value  : String
  deriving DecidableEq, Repr

structure Input where
  options : List PlugInOption
  deriving DecidableEq, Repr

structure Output where
  options : List PlugInOption
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.options.Nodup
  post := fun i o => o.options = i.options.map (fun opt => 
    if opt.name = "someOptionName" then 
      { opt with value := "newOptionValue" }
    else 
      opt)

example : Spec.pre { options := [{ name := "someOptionName", value := "oldOptionValue" },
                                  { name := "anotherOptionName", value := "anotherValue" }] } ∧
          Spec.post { options := [{ name := "someOptionName", value := "newOptionValue" },
                                   { name := "anotherOptionName", value := "anotherValue" }] }
                    { options := [{ name := "someOptionName", value := "newOptionValue" },
                                  { name := "anotherOptionName", value := "anotherValue" }] } := by
  unfold Spec; decide
