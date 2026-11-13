import ContractForge
open ContractForge

-- 4/audit-module/R2: Once the audit trail functionality has been activated, the System must track events without manual intervention, and store in the audit trail information about them.
-- compiles: False · rejects_bad_example: None · checked: False

structure Event where
  timestamp : Nat
  description : String
  deriving DecidableEq, Repr

structure Input where
  activated : Bool
  events    : List Event
  deriving DecidableEq, Repr

structure Output where
  activated : Bool
  events    : List Event
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.activated = true
  post := fun i o => o.activated = true ∧
                     (o.events.length = i.events.length + 1 ∧
                      o.events.last.timestamp = i.events.length + 1 ∧
                      o.events.last.description ≠ "")

example : Spec.pre { activated := true, events := [] } ∧
          Spec.post { activated := true, events := [] }
                    { activated := true, events := [{ timestamp := 1, description := "Event occurred" }] } := by
  unfold Spec; decide
