import ContractForge
open ContractForge

-- 2.3.1.1/S1: The Project Team shall schedule updates to the production environment only on Tuesdays between 7pm and 7am.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  dayOfWeek : Nat -- 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  timeOfDay : Nat -- in minutes since midnight
  updateScheduled : Bool
  deriving DecidableEq, Repr

structure Output where
  updateScheduled : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dayOfWeek = 2 ∧ 420 ≤ i.timeOfDay ∧ i.timeOfDay ≤ 43800
  post := fun i o => o.updateScheduled = true ↔ i.updateScheduled = true

example : Spec.pre { dayOfWeek := 2, timeOfDay := 4320, updateScheduled := true } ∧
          Spec.post { dayOfWeek := 2, timeOfDay := 4320, updateScheduled := true }
                    { updateScheduled := true } := by
  unfold Spec; decide
