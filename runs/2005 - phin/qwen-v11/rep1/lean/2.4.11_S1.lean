import ContractForge
open ContractForge

-- 2.4.11/S1: Health event data should be aggregated into a centralized data store (i.e., data warehouse) designed specifically to support analysis of events over time.
-- compiles: True · rejects_bad_example: True · checked: True

structure EventData where
  date       : Nat -- day of the year
  location   : String
  severity   : Nat -- on a scale of 1 to 10
  num_cases  : Nat
  deriving DecidableEq, Repr

structure Input where
  events : List EventData
  deriving DecidableEq, Repr

structure Output where
  aggregated : List EventData
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.events.Nodup
  post := fun i o => o.aggregated.length = i.events.length ∧
                     (∀ e ∈ i.events, ∃ a ∈ o.aggregated, a.date = e.date ∧
                      a.location = e.location ∧ a.severity = e.severity ∧
                      a.num_cases = e.num_cases)

example : Spec.pre { events := [{ date := 1, location := "A", severity := 5, num_cases := 10 },
                                 { date := 2, location := "B", severity := 7, num_cases := 20 }] } ∧
          Spec.post { events := [{ date := 1, location := "A", severity := 5, num_cases := 10 },
                                  { date := 2, location := "B", severity := 7, num_cases := 20 }] }
                    { aggregated := [{ date := 1, location := "A", severity := 5, num_cases := 10 },
                                     { date := 2, location := "B", severity := 7, num_cases := 20 }] } := by
  unfold Spec; decide
