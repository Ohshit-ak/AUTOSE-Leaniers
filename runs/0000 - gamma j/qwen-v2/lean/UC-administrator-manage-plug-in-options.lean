-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- checked: True

structure Input where
  plugInId : Nat
  options  : List String
  deriving DecidableEq, Repr

structure Output where
  plugInId : Nat
  options  : List String
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugInId ≠ 0
  post := fun i o => o.confirmed = true ∧
                     o.plugInId = i.plugInId ∧
                     o.options = i.options

example : Spec.pre { plugInId := 1, options := ["opt1", "opt2"] } ∧
          Spec.post { plugInId := 1, options := ["opt1", "opt2"] }
                    { plugInId := 1, options := ["opt1", "opt2"], confirmed := true } := by
  unfold Spec; decide
