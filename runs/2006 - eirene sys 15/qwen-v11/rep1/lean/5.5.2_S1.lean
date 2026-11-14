import ContractForge
open ContractForge

-- 5.5.2/S1: The sequence of actions for a mobile terminated call to a driver shall be as follows: (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Call where
  callerID : String
  driverID : String
  status   : String
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  deriving DecidableEq, Repr

structure Output where
  calls : List Call
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.calls.length > 0 ∧
                   ∃ c ∈ i.calls, c.status = "mobile terminated" ∧
                   c.callerID ≠ "" ∧ c.driverID ≠ ""
  post := fun i o => o.calls.length = i.calls.length ∧
                     ∀ c ∈ o.calls, c.callerID = i.calls.find? (·.callerID = c.callerID).get!.callerID ∧
                     c.driverID = i.calls.find? (·.callerID = c.callerID).get!.driverID ∧
                     c.status = "handled" ∧
                     (c.status = "handled" ↔
                      (c.callerID = i.calls.find? (·.callerID = c.callerID).get!.callerID ∧
                       c.driverID = i.calls.find? (·.callerID = c.callerID).get!.driverID))

example : Spec.pre { calls := [{ callerID := "123", driverID := "456", status := "mobile terminated" }] } ∧
          Spec.post { calls := [{ callerID := "123", driverID := "456", status := "handled" }] }
                    { calls := [{ callerID := "123", driverID := "456", status := "handled" }] } := by
  unfold Spec; decide
