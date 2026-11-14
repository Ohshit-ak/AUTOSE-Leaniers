import ContractForge
open ContractForge

-- 11.3.8/S1: The network operator shall implement the required functionality to validate the information exchanged between the mobile and network on registration and deregistration.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mobileNumber : String
  deriving DecidableEq, Repr

structure Output where
  isValid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileNumber ≠ ""
  post := fun i o => o.isValid = true ↔
    (i.mobileNumber.toList.all Char.isDigit = true) ∧
    (i.mobileNumber.length = 10)

example : Spec.pre { mobileNumber := "1234567890" } ∧
          Spec.post { mobileNumber := "1234567890" }
                    { isValid := true } := by
  unfold Spec; decide
