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
    if opt.name = "exampleOption" then 
      { opt with value := "newValue" } 
    else 
      opt)

example : Spec.pre { options := [{ name := "exampleOption", value := "oldValue" },
                                  { name := "otherOption", value := "someValue" }] } ∧
          Spec.post { options := [{ name := "exampleOption", value := "newValue" },
                                   { name := "otherOption", value := "someValue" }] }
                    { options := [{ name := "exampleOption", value := "newValue" },
                                  { name := "otherOption", value := "someValue" }] } := by
  unfold Spec; decide
