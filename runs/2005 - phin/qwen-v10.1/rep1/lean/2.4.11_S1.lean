import ContractForge
open ContractForge

-- 2.4.11/S1: Health event data should be aggregated into a centralized data store (i.e., data warehouse) designed specifically to support analysis of events over time.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  events : List String
  deriving DecidableEq, Repr

structure Output where
  aggregated : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.events.Nodup
  post := fun i o => o.aggregated.length = i.events.length ∧
                     o.aggregated.Nodup ∧
                     ∀ e ∈ i.events, o.aggregated.contains e

example : Spec.pre { events := ["event1", "event2", "event3"] } ∧
          Spec.post { events := ["event1", "event2", "event3"] }
                    { aggregated := ["event1", "event2", "event3"] } := by
  unfold Spec; decide
