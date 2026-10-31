import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  queryFrom : String
  deriving DecidableEq, Repr

structure Output where
  sentToAdmin : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryFrom ≠ ""
  post := fun i o => o.sentToAdmin = true ↔
    i.queryFrom = "technical query from customer or sales person"

example : Spec.pre { queryFrom := "technical query from customer or sales person" } ∧
          Spec.post { queryFrom := "technical query from customer or sales person" }
                    { sentToAdmin := true } := by
  unfold Spec; decide
