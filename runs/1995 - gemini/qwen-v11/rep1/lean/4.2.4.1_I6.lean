import ContractForge
open ContractForge

-- 4.2.4.1/I6: Logging System logging information should include all important events, properly timestamped and indexed. The goal is to be able to recreate the steps in a observation from the system logs.
-- compiles: False · rejects_bad_example: None · checked: False

structure LogEntry where
  event : String
  timestamp : Nat
  index : Nat
  deriving DecidableEq, Repr

structure Input where
  logs : List LogEntry
  deriving DecidableEq, Repr

structure Output where
  events : List String
  timestamps : List Nat
  indices : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logs.Nodup
  post := fun i o => 
    o.events.length = i.logs.length ∧
    o.timestamps.length = i.logs.length ∧
    o.indices.length = i.logs.length ∧
    ∀ j ∈ i.logs.indices, o.indices.contains j = true ∧
    ∀ j ∈ i.logs.indices, o.timestamps[j] = i.logs[j].timestamp ∧
    ∀ j ∈ i.logs.indices, o.events[j] = i.logs[j].event

example : Spec.pre { logs := [{ event := "Login", timestamp := 100, index := 1 },
                               { event := "Logout", timestamp := 200, index := 2 }] } ∧
          Spec.post { logs := [{ event := "Login", timestamp := 100, index := 1 },
                                { event := "Logout", timestamp := 200, index := 2 }] }
                    { events := ["Login", "Logout"], timestamps := [100, 200], indices := [1, 2] } := by
  unfold Spec; decide
