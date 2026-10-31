import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: None · checked: False

structure PlugInOption where
  name : String
  value : String
  deriving DecidableEq, Repr

structure Input where
  adminConfirmed : Bool
  plugInOptions : List PlugInOption
  deriving DecidableEq, Repr

structure Output where
  adminConfirmed : Bool
  plugInOptions : List PlugInOption
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adminConfirmed = true
  post := fun i o => o.adminConfirmed = i.adminConfirmed ∧
                     o.plugInOptions = i.plugInOptions.map (fun opt => 
                       { name := opt.name, value := "new_value" })

example : Spec.pre { adminConfirmed := true, plugInOptions := [{ name := "opt1", value := "old_value" }] } ∧
          Spec.post { adminConfirmed := true, plugInOptions := [{ name := "opt1", value := "new_value" }] }
                    { adminConfirmed := true, plugInOptions := [{ name := "opt1", value := "new_value" }] } := by
  unfold Spec; decide
