-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- checked: True

structure Input where
  plugIns : List String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List String
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugIns.length > 0
  post := fun i o => o.removed = true ∧
                     o.plugIns = i.plugIns.filter (fun p => p ≠ "plug-in-to-remove")

example : Spec.pre { plugIns := ["plug-in-to-remove", "another-plugin"] } ∧
          Spec.post { plugIns := ["plug-in-to-remove", "another-plugin"] }
                    { plugIns := ["another-plugin"], removed := true } := by
  unfold Spec; decide
