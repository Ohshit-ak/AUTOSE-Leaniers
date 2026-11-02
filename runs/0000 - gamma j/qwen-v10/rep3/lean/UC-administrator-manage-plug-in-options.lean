import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: None · checked: False

structure PlugInOption where
  name  : String
  value : String
  deriving DecidableEq, Repr

structure Input where
  administratorConfirmed : Bool
  options               : List PlugInOption
  deriving DecidableEq, Repr

structure Output where
  administratorConfirmed : Bool
  options               : List PlugInOption
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.administratorConfirmed = true
  post := fun i o => (o.administratorConfirmed = true) ∧
                     (o.options.length = i.options.length) ∧
                     (∀ opt ∈ o.options, ∃ i_opt ∈ i.options, i_opt.name = opt.name ∧ i_opt.value = opt.value)

example : Spec.pre { administratorConfirmed := true,
                     options := [{ name := "logLevel", value := "debug" },
                                 { name := "timeout", value := "30" }] }
          ∧ Spec.post { administratorConfirmed := true,
                        options := [{ name := "logLevel", value := "info" },
                                    { name := "timeout", value := "60" }] }
                     { administratorConfirmed := true,
                       options := [{ name := "logLevel", value := "info" },
                                   { name := "timeout", value := "60" }] } := by
  unfold Spec; decide
