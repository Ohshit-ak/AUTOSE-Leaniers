import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  queryFrom : String
  queryType : String
  deriving DecidableEq, Repr

structure Output where
  emailSent : Bool
  emailTo   : String
  emailBody : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryType = "technical"
  post := fun i o => o.emailSent = true ∧
                     o.emailTo = "admin@example.com" ∧
                     o.emailBody = "Query from: " ++ i.queryFrom ++ " Type: " ++ i.queryType

example : Spec.pre { queryFrom := "customer@example.com", queryType := "technical" } ∧
          Spec.post { queryFrom := "customer@example.com", queryType := "technical" }
                    { emailSent := true, emailTo := "admin@example.com", emailBody := "Query from: customer@example.com Type: technical" } := by
  unfold Spec; decide
