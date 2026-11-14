import ContractForge
open ContractForge

-- 3.1.5.1.3/S7: If the queue is not empty, this process shall remove one request from the LIFO queue and check the current state of the thermostat for which the queued request was made.
-- compiles: False · rejects_bad_example: None · checked: False

structure Request where
  thermostatId : Nat
  deriving DecidableEq, Repr

structure Input where
  queue : List Request
  thermostatStates : List (Nat × Bool)
  deriving DecidableEq, Repr

structure Output where
  thermostatId : Nat
  thermostatState : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queue.Nodup ∧ i.queue.length > 0
  post := fun i o => 
    (o.thermostatId = i.queue.last.thermostatId ∧
     o.thermostatState = i.thermostatStates.find? (fun (id, _) => id = o.thermostatId).get! false)

example : Spec.pre { queue := [{ thermostatId := 1 }], thermostatStates := [(1, true)] } ∧
          Spec.post { queue := [{ thermostatId := 1 }], thermostatStates := [(1, true)] }
                    { thermostatId := 1, thermostatState := true } := by
  unfold Spec; decide
