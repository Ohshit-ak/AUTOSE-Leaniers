import ContractForge
open ContractForge

-- 4.4.3/S1: If the attempt to establish a Railway emergency call is not successful after 2 seconds, an indication shall be provided to the user of the status of the establishment request procedure.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  indicationProvided : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.indicationProvided = true ↔ o.elapsedMicros ≤ 2000000

example : Spec.pre { } ∧ Spec.post { elapsedMicros := 1999999, indicationProvided := true } := by
  unfold Spec; decide
