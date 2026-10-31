import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: None · checked: True

structure PlugInOption where
  name : String
  value : String
  deriving DecidableEq, Repr

structure Input where
  adminConfirmed : Bool
  options : List PlugInOption
  deriving DecidableEq, Repr

structure Output where
  adminConfirmed : Bool
  options : List PlugInOption
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adminConfirmed
  post := fun i o => (o.adminConfirmed = i.adminConfirmed) ∧
                     (o.options = i.options.map (fun opt => { name := opt.name, value := opt.value }))

example : Spec.pre { adminConfirmed := true, options := [{ name := "option1", value := "value1" }] } ∧
          Spec.post { adminConfirmed := true, options := [{ name := "option1", value := "value1" }] }
                    { adminConfirmed := true, options := [{ name := "option1", value := "value1" }] } := by
  unfold Spec; decide
