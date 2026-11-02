import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: True · checked: True

structure PlugInOption where
  name   : String
  value  : String
  enabled : Bool
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
                     o.options.length = i.options.length ∧
                     ∀ opt ∈ o.options, ∃ io ∈ i.options, opt.name = io.name ∧
                     (opt.value = io.value ∧ opt.enabled = io.enabled ↔
                      ∃ io ∈ i.options, opt.name = io.name ∧
                      (io.value ≠ opt.value ∨ io.enabled ≠ opt.enabled))

example : Spec.pre { options := [] } ∧ Spec.post { options := [] } { options := [], confirmed := true } := by
  unfold Spec; decide
