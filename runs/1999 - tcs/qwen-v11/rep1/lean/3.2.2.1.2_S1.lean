import ContractForge
open ContractForge

-- 3.2.2.1.2/S1: The TCS shall have the capability to command the AV to use the navigation methods inherent to the selected AV. [SSS130] The operator shall have the capability to initiate as well as change, to include as a minimum manual override, UAV navigation methods by sending the proper control commands to the UAV. [SSS131]
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  navigationMethod : String
  overrideMode     : Bool
  deriving DecidableEq, Repr

structure Output where
  navigationMethod : String
  overrideMode     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.navigationMethod ≠ "" ∧ (i.overrideMode = true ∨ i.overrideMode = false)
  post := fun i o => (o.navigationMethod = i.navigationMethod ∧ o.overrideMode = i.overrideMode) ↔
                     (i.overrideMode = true → o.navigationMethod = "manual" ∨ o.navigationMethod = i.navigationMethod) ∧
                     (i.overrideMode = false → o.navigationMethod = i.navigationMethod)

example : Spec.pre { navigationMethod := "auto", overrideMode := true } ∧ Spec.post { navigationMethod := "auto", overrideMode := true } { navigationMethod := "", overrideMode := true } := by
  unfold Spec; decide
