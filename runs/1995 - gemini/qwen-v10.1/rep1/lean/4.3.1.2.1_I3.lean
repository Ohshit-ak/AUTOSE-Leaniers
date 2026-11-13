import ContractForge
open ContractForge

-- 4.3.1.2.1/I3: Databases Scanning Database scanning is the mechanism for deciding when to process a record. Four types of scanning are possible: Periodic, Event, I/O Event, and Passive. Periodic: A request can be made to process a record periodically. A number of time intervals are supported. Event: Event scanning is based on the posting of an event by any IOC software component. The actual subroutine call is: post_event(event_num) I/O Event: The I/O event scanning system processes records based on external interrupts. An IOC device driver interrupt routine must be available to accept the external interrupts. Passive: Passive records are processed as a result of linked records being processed or as a result of external changes such as channel access puts.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  record_type : String
  period      : Option Nat
  deriving DecidableEq, Repr

structure Output where
  processed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.record_type ∈ ["Event", "I/O Event", "Passive"]
  post := fun i o => (o.processed = true ↔
    (i.record_type = "Event" → post_event(i.period.getD 0) = true) ∧
    (i.record_type = "I/O Event" → interrupt_handler(i.period.getD 0) = true) ∧
    (i.record_type = "Passive" → ∃ r ∈ i.period.getD [], r.processed = true))

example : Spec.pre { record_type := "Event", period := some 5 } ∧
          Spec.post { record_type := "Event", period := some 5 }
                    { processed := true } := by
  unfold Spec; decide

example : Spec.pre { record_type := "I/O Event", period := some 10 } ∧
          Spec.post { record_type := "I/O Event", period := some 10 }
                    { processed := true } := by
  unfold Spec; decide

example : Spec.pre { record_type := "Passive", period := none } ∧
          Spec.post { record_type := "Passive", period := none }
                    { processed := true } := by
  unfold Spec; decide
