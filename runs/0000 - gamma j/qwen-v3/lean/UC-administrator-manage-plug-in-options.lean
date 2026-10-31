-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- checked: True

structure Input where
  adminConfirmed : Bool
  plugInOptions  : String
  deriving DecidableEq, Repr

structure Output where
  adminConfirmed : Bool
  plugInOptions  : String
  changed        : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adminConfirmed = true
  post := fun i o => o.adminConfirmed = i.adminConfirmed ∧
                     o.plugInOptions = i.plugInOptions ∧
                     o.changed = true

example : Spec.pre { adminConfirmed := true, plugInOptions := "option1" } ∧
          Spec.post { adminConfirmed := true, plugInOptions := "option1" }
                    { adminConfirmed := true, plugInOptions := "option1", changed := true } := by
  unfold Spec; decide
