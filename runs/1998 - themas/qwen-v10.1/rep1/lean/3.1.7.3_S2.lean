import ContractForge
open ContractForge

-- 3.1.7.3/S2: If the system detects an invalid temperature, this process shall output a continuous series of alternating 500 Hz and 700 Hz beeps on the supervisor's computer.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  invalidTemperature : Bool
  deriving DecidableEq, Repr

structure Output where
  beepFrequencies : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.invalidTemperature
  post := fun i o => o.beepFrequencies.length % 2 = 1 ∧
                     o.beepFrequencies.length ≥ 1 ∧
                     o.beepFrequencies.length ≤ 100 ∧
                     o.beepFrequencies.all (fun f => f = 500 ∨ f = 700) ∧
                     o.beepFrequencies.Nodup ∧
                     (o.beepFrequencies.length = 1 → o.beepFrequencies = [500]) ∧
                     (o.beepFrequencies.length = 3 → o.beepFrequencies = [500, 700, 500]) ∧
                     (o.beepFrequencies.length = 5 → o.beepFrequencies = [500, 700, 500, 700, 500]) ∧
                     (o.beepFrequencies.length = 7 → o.beepFrequencies = [500, 700, 500, 700, 500, 700, 500]) ∧
                     (o.beepFrequencies.length = 9 → o.beepFrequencies = [500, 700, 500, 700, 500, 700, 500, 700, 500])

example : Spec.pre { invalidTemperature := true } ∧
          Spec.post { invalidTemperature := true }
                    { beepFrequencies := [500, 700, 500, 700, 500] } := by
  unfold Spec; decide
