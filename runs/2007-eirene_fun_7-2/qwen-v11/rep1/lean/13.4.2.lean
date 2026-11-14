import ContractForge
open ContractForge

-- 13.4.2: 13.4.2 The confirmation shall be generated automatically without input from the user. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  emergencyCallId : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmationGenerated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.confirmationGenerated = true

example : Spec.pre { emergencyCallId := 12345 } ∧ Spec.post { emergencyCallId := 12345 }
          { confirmationGenerated := true } := by
  unfold Spec; decide
