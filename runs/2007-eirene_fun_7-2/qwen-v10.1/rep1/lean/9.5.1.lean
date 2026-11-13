import ContractForge
open ContractForge

-- 9.5.1: 9.5.1 Authorised users within the EIRENE network shall be able to receive calls from calling parties outside the EIRENE network. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callerNumber : String
  calledNumber : String
  callerNetwork : String
  calledNetwork : String
  callerAuthorised : Bool
  deriving DecidableEq, Repr

structure Output where
  callAccepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callerNetwork ≠ "" ∧ i.calledNetwork ≠ "" ∧ i.callerAuthorised
  post := fun i o => (o.callAccepted = true ↔
    i.callerNetwork ≠ i.calledNetwork ∧ i.callerAuthorised)

example : Spec.pre { callerNumber := "1234567890", calledNumber := "0987654321",
                     callerNetwork := "external", calledNetwork := "EIRENE",
                     callerAuthorised := true } ∧
          Spec.post { callerNumber := "1234567890", calledNumber := "0987654321",
                      callerNetwork := "external", calledNetwork := "EIRENE",
                      callerAuthorised := true }
                    { callAccepted := true } := by
  unfold Spec; decide
