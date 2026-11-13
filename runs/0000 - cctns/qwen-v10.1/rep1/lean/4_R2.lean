import ContractForge
open ContractForge

-- 4/R2: The solution should send alerts (e.g., email, SMS) to the user if the user chooses to whenever any action has been taken on the alert.
-- compiles: True · rejects_bad_example: True · checked: True

structure Alert where
  user   : String
  message: String
  sent   : Nat
  deriving DecidableEq, Repr

structure Input where
  user   : String
  message: String
  alert  : Alert
  deriving DecidableEq, Repr

structure Output where
  alert  : Alert
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user ≠ ""
  post := fun i o => (o.alert.sent = i.alert.sent + 1 ↔
    i.alert.user = i.user ∧ i.alert.message = i.message)

example : Spec.pre { user := "alice", message := "Alert message", alert := { user := "alice", message := "Alert message", sent := 0 } } ∧
          Spec.post { user := "alice", message := "Alert message", alert := { user := "alice", message := "Alert message", sent := 0 } }
                    { alert := { user := "alice", message := "Alert message", sent := 1 } } := by
  unfold Spec; decide
