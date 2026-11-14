import ContractForge
open ContractForge

-- 2.2.2.1/S1: When a health event is investigated, it must be assigned an event identifier (i.e., Event ID) that is unique within the jurisdiction.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  eventIdentifier : String
  jurisdiction    : String
  deriving DecidableEq, Repr

structure Output where
  eventIdentifier : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.eventIdentifier ≠ ""
  post := fun i o => o.eventIdentifier = i.eventIdentifier ∧
                     (o.eventIdentifier.toList.all (fun c => c.isAlphanum) = true) ∧
                     (o.eventIdentifier.length = 10) ∧
                     (i.eventIdentifier = o.eventIdentifier) ∧
                     (i.jurisdiction = o.jurisdiction) ∧
                     (∃ e, e.eventIdentifier = o.eventIdentifier ∧ e.jurisdiction = o.jurisdiction)

example : Spec.pre { eventIdentifier := "J123456789", jurisdiction := "XYZ" } ∧
          Spec.post { eventIdentifier := "J123456789", jurisdiction := "XYZ" }
                    { eventIdentifier := "J123456789", jurisdiction := "XYZ" } := by
  unfold Spec; decide
