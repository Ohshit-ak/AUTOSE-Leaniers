-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- checked: False

structure Input where
  plugIns : List String
  removed : Bool
  deriving DecidableEq, Repr

structure Output where
  plugIns : List String
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugIns.length > 0
  post := fun i o => o.removed = true ∧
                     o.plugIns = i.plugIns.filter (· ∉ i.plugIns)

example : Spec.pre { plugIns := ["plug-in1", "plug-in2"], removed := false } ∧
          Spec.post { plugIns := ["plug-in1", "plug-in2"], removed := false }
                    { plugIns := ["plug-in1"], removed := true } := by
  unfold Spec; decide

structure Input where
  plugIns : List String
  removed : Bool
  deriving DecidableEq, Repr

structure Output where
  plugIns : List String
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugIns.length > 0
  post := fun i o => o.removed = true ∧
                     o.plugIns = i.plugIns.filter (· ∉ i.plugIns)

example : Spec.pre { plugIns := ["plug-in1", "plug-in2"], removed := false } ∧
          Spec.post { plugIns := ["plug-in1", "plug-in2"], removed := false }
                    { plugIns := ["plug-in1"], removed := true } := by
  unfold Spec; decide
