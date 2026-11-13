import ContractForge
open ContractForge

-- 11.3.8/S1: The network operator shall implement the required functionality to validate the information exchanged between the mobile and network on registration and deregistration.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  mobileNumber : String
  networkNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileNumber ≠ "" ∧ i.networkNumber ≠ ""
  post := fun i o => o.valid = true ↔
    (i.mobileNumber.length = 10 ∧ i.networkNumber.length = 10 ∧
     i.mobileNumber.toList.all Char.isDigit = true ∧ i.networkNumber.toList.all Char.isDigit = true)

example : Spec.pre { mobileNumber := "1234567890", networkNumber := "1234567890" } ∧
          Spec.post { mobileNumber := "1234567890", networkNumber := "1234567890" }
                    { valid := true } := by
  unfold Spec; decide
