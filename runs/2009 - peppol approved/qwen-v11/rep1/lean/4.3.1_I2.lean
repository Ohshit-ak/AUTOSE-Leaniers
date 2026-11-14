import ContractForge
open ContractForge

-- 4.3.1/I2: flexibility to meet the dynamics of the organisational and legal changes and
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  currentState : String
  changesApplied : Nat
  deriving DecidableEq, Repr

structure Output where
  newState : String
  changesApplied : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentState ≠ ""
  post := fun i o => o.newState = i.currentState ++ " (updated)" ∧
                     o.changesApplied = i.changesApplied + 1

example : Spec.pre { currentState := "Austrian legal framework", changesApplied := 0 } ∧
          Spec.post { currentState := "Austrian legal framework", changesApplied := 0 }
                    { newState := "Austrian legal framework (updated)", changesApplied := 1 } := by
  unfold Spec; decide
