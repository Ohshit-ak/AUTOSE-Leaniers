import ContractForge
open ContractForge

-- 2.2.2.1/S1: When a health event is investigated, it must be assigned an event identifier (i.e., Event ID) that is unique within the jurisdiction.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  eventIdentifier : String
  deriving DecidableEq, Repr

def ComputeEventIdentifierContract : Contract Input Mid where
  pre  := fun i => i.eventIdentifier ≠ ""
  post := fun i m => m.eventIdentifier = i.eventIdentifier

def ProcessJurisdictionContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.eventIdentifier = m.eventIdentifier ∧
                     (i.jurisdiction = m.jurisdiction → o.eventIdentifier ≠ m.eventIdentifier)
