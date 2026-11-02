import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: None · checked: True

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
  post := fun i o => o.options.length = i.options.length ∧
                     (∀ opt ∈ i.options, ∃ newOpt ∈ o.options, newOpt.name = opt.name ∧
                      newOpt.value ≠ opt.value)

example : Spec.pre { options := [] } ∧ Spec.post { options := [] } { options := [] } := by
  unfold Spec; decide
