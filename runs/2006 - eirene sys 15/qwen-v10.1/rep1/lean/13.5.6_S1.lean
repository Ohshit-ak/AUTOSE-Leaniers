import ContractForge
open ContractForge

-- 13.5.6/S1: The user information contained in the confirmation message shall be: (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  emergencyCallId : String
  userInformation : String
  deriving DecidableEq, Repr

structure Output where
  confirmationMessage : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userInformation ≠ ""
  post := fun i o => o.confirmationMessage = i.emergencyCallId ++ " - " ++ i.userInformation

example : Spec.pre { emergencyCallId := "EC1234", userInformation := "User A" } ∧
          Spec.post { emergencyCallId := "EC1234", userInformation := "User A" }
                    { confirmationMessage := "EC1234 - User A" } := by
  unfold Spec; decide
