import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  queryFrom : String
  queryType : String
  deriving DecidableEq, Repr

structure Output where
  eMailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryType = "technical"
  post := fun i o => o.eMailSent = true

example : Spec.pre { queryFrom := "customer@example.com", queryType := "technical" } ∧
          Spec.post { queryFrom := "customer@example.com", queryType := "technical" }
                    { eMailSent := true } := by
  unfold Spec; decide
