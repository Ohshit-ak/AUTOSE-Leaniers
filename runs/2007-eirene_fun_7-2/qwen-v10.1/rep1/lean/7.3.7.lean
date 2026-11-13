import ContractForge
open ContractForge

-- 7.3.7: 7.3.7 It should be possible for a user to change the battery without the use of tools. (O)
-- compiles: False · rejects_bad_example: None · checked: False

structure Battery where
  model : String
  voltage : Nat
  deriving DecidableEq, Repr

structure Input where
  battery : Battery
  hasTools : Bool
  deriving DecidableEq, Repr

structure Output where
  battery : Battery
  hasTools : Bool
  succeeded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.hasTools = false
  post := fun i o => o.succeeded = true ∧
                     o.battery = i.battery ∧
                     o.hasTools = i.hasTools

example : Spec.pre { battery := { model := "AA", voltage := 1.5 }, hasTools := false } ∧
          Spec.post { battery := { model := "AA", voltage := 1.5 }, hasTools := false }
                    { battery := { model := "AA", voltage := 1.5 }, hasTools := false, succeeded := true } := by
  unfold Spec; decide
