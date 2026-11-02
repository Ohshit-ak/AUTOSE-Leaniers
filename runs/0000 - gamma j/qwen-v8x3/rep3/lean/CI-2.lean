import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  queryFrom : String
  queryType : String
  deriving DecidableEq, Repr

structure Output where
  sentTo : String
  queryFrom : String
  queryType : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryType = "technical"
  post := fun i o => o.sentTo = "system.administrator@example.com" ∧
                     o.queryFrom = i.queryFrom ∧
                     o.queryType = i.queryType

example : Spec.pre { queryFrom := "customer@example.com", queryType := "technical" } ∧
          Spec.post { queryFrom := "customer@example.com", queryType := "technical" }
                    { sentTo := "system.administrator@example.com", queryFrom := "customer@example.com", queryType := "technical" } := by
  unfold Spec; decide
