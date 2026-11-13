import ContractForge
open ContractForge

-- 2.2.2.1/S1: When a health event is investigated, it must be assigned an event identifier (i.e., Event ID) that is unique within the jurisdiction.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  eventIdentifier : String
  jurisdiction    : String
  deriving DecidableEq, Repr

structure Output where
  eventIdentifier : String
  jurisdiction    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.eventIdentifier ≠ ""
  post := fun i o => o.eventIdentifier = i.eventIdentifier ∧
                     (i.jurisdiction = o.jurisdiction →
                      o.eventIdentifier ≠ i.eventIdentifier)

example : Spec.pre { eventIdentifier := "E123", jurisdiction := "NY" } ∧ Spec.post { eventIdentifier := "E123", jurisdiction := "NY" } { eventIdentifier := "E123", jurisdiction := "" } := by
  unfold Spec; decide
