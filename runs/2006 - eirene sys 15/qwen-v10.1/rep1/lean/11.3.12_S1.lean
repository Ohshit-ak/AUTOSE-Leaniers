import ContractForge
open ContractForge

-- 11.3.12/S1: The result of the deregistration procedure shall be sent back to the mobile.
-- compiles: True · rejects_bad_example: True · checked: True

structure Mobile where
  number : Nat
  deriving DecidableEq, Repr

structure DeregistrationResult where
  success : Bool
  message : String
  deriving DecidableEq, Repr

structure Input where
  mobileNumber : Nat
  exists_       : Bool
  deriving DecidableEq, Repr

structure Output where
  mobileNumber : Nat
  result       : DeregistrationResult
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileNumber ≠ 0
  post := fun i o => o.mobileNumber = i.mobileNumber ∧
                     (o.result.success = true ↔ i.exists_) ∧
                     (o.result.success = false →
                      (i.exists_ → o.result.message = "Mobile number not found") ∧
                      (¬ i.exists_ → o.result.message = "Deregistration successful"))

example : Spec.pre { mobileNumber := 12345, exists_ := true } ∧ Spec.post { mobileNumber := 12345, exists_ := true } { mobileNumber := 12345, result := { success := true, message := "" } } := by
  unfold Spec; decide
