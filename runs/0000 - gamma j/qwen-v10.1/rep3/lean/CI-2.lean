import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  queryFrom : String
  sender    : String
  deriving DecidableEq, Repr

structure Output where
  sentTo     : String
  subject    : String
  body       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryFrom ≠ "" ∧ i.sender = "admin"
  post := fun i o => o.sentTo = "admin@example.com" ∧
                     o.subject = "Technical Query from " ++ i.queryFrom ∧
                     o.body = "Query from: " ++ i.queryFrom ++ "\nSender: " ++ i.sender

example : Spec.pre { queryFrom := "network issue", sender := "admin" } ∧
          Spec.post { queryFrom := "network issue", sender := "admin" }
                    { sentTo := "admin@example.com", subject := "Technical Query from network issue", body := "Query from: network issue\nSender: admin" } := by
  unfold Spec; decide
