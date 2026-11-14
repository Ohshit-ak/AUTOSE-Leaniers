import ContractForge
open ContractForge

-- 4.3.5/S1: If a Railway emergency call set up from an EIRENE radio is unsuccessful, the radio shall automatically re-attempt the call setup until the call setup is successful, a retry timer expires (duration 30 seconds, as specified in the [EIRENE FRS]) or the user abandons the call.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  successful : Bool
  abandoned  : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => (o.successful = true ∨ o.abandoned = true) ∧
                     (o.successful = true → o.elapsedMicros ≤ 30000000) ∧
                     (o.abandoned = true → o.elapsedMicros ≤ 30000000)

example : Spec.pre { } ∧
          Spec.post { successful := false, abandoned := true, elapsedMicros := 29000000 } := by
  unfold Spec; decide
