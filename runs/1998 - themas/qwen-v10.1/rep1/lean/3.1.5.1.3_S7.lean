import ContractForge
open ContractForge

-- 3.1.5.1.3/S7: If the queue is not empty, this process shall remove one request from the LIFO queue and check the current state of the thermostat for which the queued request was made.
-- compiles: False · rejects_bad_example: None · checked: False

structure Request where
  thermostatId : Nat
  deriving DecidableEq, Repr

structure Input where
  queue : List Request
  deriving DecidableEq, Repr

structure Output where
  thermostatId : Nat
  status       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queue.Nodup ∧ i.queue.length > 0
  post := fun i o => o.thermostatId = i.queue.last.thermostatId ∧
                     o.status = "checked" -- IMPL: Check thermostat status

example : Spec.pre { queue := [{ thermostatId := 1 }] } ∧
          Spec.post { queue := [{ thermostatId := 1 }] }
                    { thermostatId := 1, status := "checked" } := by
  unfold Spec; decide
