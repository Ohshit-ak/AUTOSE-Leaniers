import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: False · checked: False

structure PluginOption where
  name : String
  value : String
  deriving DecidableEq, Repr

structure Input where
  adminConfirmed : Bool
  options : List PluginOption
  deriving DecidableEq, Repr

structure Output where
  adminConfirmed : Bool
  options : List PluginOption
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adminConfirmed = true
  post := fun i o => o.adminConfirmed = i.adminConfirmed ∧
                     (o.options.length = i.options.length ∧
                      ∀ j ∈ i.options, ∃ k ∈ o.options, k.name = j.name ∧
                      (k.value = j.value ↔ (k.value = j.value ∧ k.value ≠ "default")))

example : Spec.pre { adminConfirmed := true, options := [{ name := "theme", value := "dark" }] } ∧
          Spec.post { adminConfirmed := true, options := [{ name := "theme", value := "dark" }] }
                    { adminConfirmed := true, options := [{ name := "theme", value := "dark" }] } := by
  unfold Spec; decide
