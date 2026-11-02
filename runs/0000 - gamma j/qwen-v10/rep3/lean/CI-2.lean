import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  queryFrom : String
  sender    : String
  deriving DecidableEq, Repr

structure Output where
  sentTo    : String
  message   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryFrom ≠ "" ∧ i.sender = "customer" ∨ i.sender = "sales person"
  post := fun i o => o.sentTo = "system administrator" ∧
                     o.message = "Query from " ++ i.sender ++ ": " ++ i.queryFrom

example : Spec.pre { queryFrom := "Help with payment options", sender := "customer" } ∧
          Spec.post { queryFrom := "Help with payment options", sender := "customer" }
                    { sentTo := "system administrator", message := "Query from customer: Help with payment options" } := by
  unfold Spec; decide
