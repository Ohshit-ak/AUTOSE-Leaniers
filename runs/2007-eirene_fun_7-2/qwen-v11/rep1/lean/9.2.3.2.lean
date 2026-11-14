import ContractForge
open ContractForge

-- 9.2.3.2: 9.2.3.2 Every on-engine/coach function shall be identified by a unique standard number. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functionName : String
  number       : Nat
  deriving DecidableEq, Repr

structure Output where
  functionNumber : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionName ≠ ""
  post := fun i o => o.functionNumber = i.number ∧
                     (o.functionNumber = i.number ↔ i.functionName ≠ "")

example : Spec.pre { functionName := "Brake System", number := 1234 } ∧
          Spec.post { functionName := "Brake System", number := 1234 }
                    { functionNumber := 1234 } := by
  unfold Spec; decide
