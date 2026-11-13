import ContractForge
open ContractForge

-- 2.3.4: 2.3.4 If the text message facility is implemented, it shall not interfere with the ability of users to make or receive high priority voice or data calls. (M) General data applications
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  user : String
  priority : Bool
  message : String
  deriving DecidableEq, Repr

structure Output where
  callSuccessful : Bool
  messageSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.priority = true
  post := fun i o => (o.callSuccessful = true ↔ i.priority = true) ∧
                     (o.messageSent = false ↔ i.message ≠ "" ∧ i.priority = true)

example : Spec.pre { user := "alice", priority := true, message := "" } ∧ Spec.post { user := "alice", priority := true, message := "" } { callSuccessful := true, messageSent := true } := by
  unfold Spec; decide
