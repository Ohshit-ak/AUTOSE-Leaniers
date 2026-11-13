import ContractForge
open ContractForge

-- 2.5.2.4/S1: The system shall send a notification email to a Client Services email distribution list if the user is directed to the xxx error page.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  userRedirected : Bool
  errorPage      : String
  clientsEmail   : String
  deriving DecidableEq, Repr

structure Output where
  notificationSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userRedirected = true ∧ i.errorPage = "xxx"
  post := fun i o => o.notificationSent = true

example : Spec.pre { userRedirected := true, errorPage := "xxx", clientsEmail := "cs@example.com" } ∧
          Spec.post { userRedirected := true, errorPage := "xxx", clientsEmail := "cs@example.com" }
                    { notificationSent := true } := by
  unfold Spec; decide
