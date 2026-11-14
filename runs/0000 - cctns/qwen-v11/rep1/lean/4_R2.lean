import ContractForge
open ContractForge

-- 4/R2: The solution should send alerts (e.g., email, SMS) to the user if the user chooses to whenever any action has been taken on the alert.
-- compiles: True · rejects_bad_example: False · checked: False

structure Alert where
  user    : String
  action  : String
  message : String
  deriving DecidableEq, Repr

structure Input where
  user    : String
  action  : String
  message : String
  alert   : Alert
  deriving DecidableEq, Repr

structure Output where
  user    : String
  action  : String
  message : String
  alert   : Alert
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user ≠ "" ∧ i.action ≠ "" ∧ i.message ≠ ""
  post := fun i o => (o.user = i.user ∧ o.action = i.action ∧ o.message = i.message) ∧
                     (o.alert = i.alert → o.alert.message = i.alert.message) ∧
                     (o.alert.message ≠ i.alert.message → o.alert = i.alert)

example : Spec.pre { user := "user1", action := "login", message := "Welcome", alert := { user := "user1", action := "login", message := "Alert sent" } } ∧
          Spec.post { user := "user1", action := "login", message := "Welcome", alert := { user := "user1", action := "login", message := "Alert sent" } }
                    { user := "user1", action := "login", message := "Welcome", alert := { user := "user1", action := "login", message := "Alert sent" } } := by
  unfold Spec; decide
