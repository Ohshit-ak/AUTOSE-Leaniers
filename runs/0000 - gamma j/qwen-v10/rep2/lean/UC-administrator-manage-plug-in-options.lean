import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: False · rejects_bad_example: None · checked: False

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
  pre  := fun i => i.options.Nodup
  post := fun i o => o.confirmed = true ∧
                     (o.options.length = i.options.length ∧
                      ∀ opt ∈ i.options, ∃ newOpt ∈ o.options, newOpt.name = opt.name ∧
                      (newOpt.value = opt.value ↔ opt.value = "default"))

example : Spec.pre { options := [{ name := "option1", value := "value1" },
                                  { name := "option2", value := "value2" }] } ∧
          Spec.post { options := [{ name := "option1", value := "value1" },
                                   { name := "option2", value := "value2" }],
                      confirmed := true } := by
  unfold Spec; decide
