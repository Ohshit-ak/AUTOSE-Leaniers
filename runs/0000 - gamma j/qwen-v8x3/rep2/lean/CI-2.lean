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
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryType = "technical"
  post := fun i o => o.sentTo = "system.admin@domain.com" ∧
                     (o.sentTo = "system.admin@domain.com" ↔
                      i.queryFrom ≠ "" ∧ i.queryType = "technical")

example : Spec.pre { queryFrom := "tech.query@customer.com", queryType := "technical" } ∧
          Spec.post { queryFrom := "tech.query@customer.com", queryType := "technical" }
                    { sentTo := "system.admin@domain.com" } := by
  unfold Spec; decide
