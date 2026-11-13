import ContractForge
open ContractForge

-- 2.3.1.1/S1: The Project Team shall schedule updates to the production environment only on Tuesdays between 7pm and 7am.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  dayOfWeek : Nat -- 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  hour      : Nat -- 00 to 23
  minute    : Nat -- 00 to 59
  deriving DecidableEq, Repr

structure Output where
  scheduled : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.scheduled = true ↔
    (i.dayOfWeek = 2 ∧
     (i.hour = 19 ∨ (i.hour = 18 ∧ i.minute = 59) ∨
      (7 ≤ i.hour ∧ i.hour < 7) ∨
      (i.hour = 7 ∧ i.minute = 0)))

example : Spec.pre { dayOfWeek := 2, hour := 19, minute := 0 } ∧
          Spec.post { dayOfWeek := 2, hour := 19, minute := 0 }
                    { scheduled := true } := by
  unfold Spec; decide
