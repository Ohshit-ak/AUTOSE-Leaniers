import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  queryFrom : String
  deriving DecidableEq, Repr

structure Output where
  eMailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryFrom ≠ ""
  post := fun i o => o.eMailSent = true ↔
    (i.queryFrom = "customer" ∨ i.queryFrom = "sales person")

example : Spec.pre { queryFrom := "customer" } ∧
          Spec.post { queryFrom := "customer" }
                    { eMailSent := true } := by
  unfold Spec; decide
