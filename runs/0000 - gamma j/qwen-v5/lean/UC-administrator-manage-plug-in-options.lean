-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- checked: True

structure Input where
  adminConfirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  adminConfirmed : Bool
  optionsChanged : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adminConfirmed = true
  post := fun i o => o.adminConfirmed = i.adminConfirmed ∧
                     o.optionsChanged = true

example : Spec.pre { adminConfirmed := true } ∧
          Spec.post { adminConfirmed := true } { adminConfirmed := true, optionsChanged := true } := by
  unfold Spec; decide
