import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  queryFrom : String
  sender    : String
  deriving DecidableEq, Repr

structure Output where
  eMailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryFrom ≠ "" ∧ i.sender = "customer" ∨ i.sender = "sales person"
  post := fun i o => o.eMailSent = true

example : Spec.pre { queryFrom := "technical issue", sender := "customer" } ∧
          Spec.post { queryFrom := "technical issue", sender := "customer" }
                    { eMailSent := true } := by
  unfold Spec; decide
