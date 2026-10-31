-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- checked: True

structure Input where
  queryFrom : String
  sender     : String
  deriving DecidableEq, Repr

structure Output where
  sentTo     : String
  subject    : String
  body       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryFrom ≠ "" ∧ i.sender = "customer" ∨ i.sender = "sales"
  post := fun i o => o.sentTo = "system.administrator" ∧
                     o.subject = "Technical Query from " ++ i.sender ++ " - " ++ i.queryFrom ∧
                     o.body = "Query from " ++ i.sender ++ ": " ++ i.queryFrom

example : Spec.pre { queryFrom := "Installation issue", sender := "customer" } ∧
          Spec.post { queryFrom := "Installation issue", sender := "customer" }
                     { sentTo := "system.administrator", subject := "Technical Query from customer - Installation issue", body := "Query from customer: Installation issue" } := by
  unfold Spec; decide
