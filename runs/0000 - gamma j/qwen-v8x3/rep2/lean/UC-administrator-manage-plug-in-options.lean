import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  plugInId : Nat
  options  : String
  deriving DecidableEq, Repr

structure Output where
  plugInId : Nat
  options  : String
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.plugInId ≠ 0 ∧ i.options ≠ ""
  post := fun i o => o.confirmed = true ∧
                     o.plugInId = i.plugInId ∧
                     o.options = i.options

example : Spec.pre { plugInId := 1, options := "new options" } ∧
          Spec.post { plugInId := 1, options := "new options" }
                     { plugInId := 1, options := "new options", confirmed := true } := by
  unfold Spec; decide
