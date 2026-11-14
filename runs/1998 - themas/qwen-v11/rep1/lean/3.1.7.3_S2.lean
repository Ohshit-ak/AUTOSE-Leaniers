import ContractForge
open ContractForge

-- 3.1.7.3/S2: If the system detects an invalid temperature, this process shall output a continuous series of alternating 500 Hz and 700 Hz beeps on the supervisor's computer.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  invalidTemperature : Bool
  deriving DecidableEq, Repr

structure Output where
  beeps : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.invalidTemperature
  post := fun i o => o.beeps.length ≥ 2 ∧
                     (o.beeps.length % 2 = 0) ∧
                     (o.beeps = [500, 700] ∨ o.beeps = [700, 500]) ∧
                     (o.beeps.length > 2 →
                      o.beeps = (o.beeps.take 2).repeat (o.beeps.length / 2))

example : Spec.pre { invalidTemperature := true } ∧
          Spec.post { invalidTemperature := true }
                    { beeps := [500, 700, 500, 700] } := by
  unfold Spec; decide
