import ContractForge
open ContractForge

-- 4.9.10.5: The driver shall be able to use the Reversing function without needing to re-confirm the train data.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  trainData : String
  deriving DecidableEq, Repr

structure Output where
  trainData : String
  reversed  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainData ≠ ""
  post := fun i o => o.trainData = i.trainData ∧
                     o.reversed = true

example : Spec.pre { trainData := "12345" } ∧
          Spec.post { trainData := "12345" }
                    { trainData := "12345", reversed := true } := by
  unfold Spec; decide
