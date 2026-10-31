-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- checked: False

structure Input where
  plugIns : List String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List String
  removed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugIns.Nodup
  post := fun i o => o.removed ∈ i.plugIns ∧
                     o.plugIns = i.plugIns.filter (· ≠ o.removed)

example : Spec.pre { plugIns := ["plug-in1", "plug-in2"] } ∧
          Spec.post { plugIns := ["plug-in1", "plug-in2"], removed := "plug-in1" }
                     { plugIns := ["plug-in2"], removed := "plug-in1" } := by
  unfold Spec; decide
