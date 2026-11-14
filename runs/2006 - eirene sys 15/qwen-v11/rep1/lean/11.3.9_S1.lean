import ContractForge
open ContractForge

-- 11.3.9/S1: The result of the registration procedure shall be sent back to the mobile.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mobileNumber : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileNumber ≠ ""
  post := fun i o => (o.success = true ↔
    i.mobileNumber.toList.all Char.isDigit = true) ∧
                     (o.success = false → o.message = "Invalid mobile number")

example : Spec.pre { mobileNumber := "1234567890" } ∧
          Spec.post { mobileNumber := "1234567890" }
                    { success := true, message := "" } := by
  unfold Spec; decide
