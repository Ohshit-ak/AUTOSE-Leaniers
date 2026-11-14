import ContractForge
open ContractForge

-- 7.3.7: 7.3.7 It should be possible for a user to change the battery without the use of tools. (O)
-- compiles: True · rejects_bad_example: None · checked: True

structure Battery where
  model : String
  voltage : Nat
  deriving DecidableEq, Repr

structure User where
  toolsAvailable : Bool
  deriving DecidableEq, Repr

structure Input where
  battery : Battery
  user    : User
  deriving DecidableEq, Repr

structure Output where
  battery : Battery
  user    : User
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user.toolsAvailable = false
  post := fun i o => o.success = true ∧
                     o.battery = i.battery ∧
                     o.user.toolsAvailable = i.user.toolsAvailable

example : Spec.pre { battery := { model := "model1", voltage := 3 }, user := { toolsAvailable := false } } ∧
          Spec.post { battery := { model := "model1", voltage := 3 }, user := { toolsAvailable := false } }
                     { success := true, battery := { model := "model1", voltage := 3 }, user := { toolsAvailable := false } } := by
  unfold Spec; decide
