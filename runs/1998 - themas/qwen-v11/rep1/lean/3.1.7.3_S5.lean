import ContractForge
open ContractForge

-- 3.1.7.3/S5: If the system detects a temperature limit has been exceeded, this process shall output a continuous series of alternating 1000 Hz and 1500 Hz beeps on the supervisor's computer.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  temperature : Nat
  limit       : Nat
  deriving DecidableEq, Repr

structure Output where
  beepFrequency : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature > i.limit
  post := fun i o => (o.beepFrequency = 1000 ↔ i.temperature > i.limit) ∧
                     (o.beepFrequency = 1500 ↔ i.temperature > i.limit) ∧
                     (o.beepFrequency = 1000 → o.beepFrequency ≠ 1500) ∧
                     (o.beepFrequency = 1500 → o.beepFrequency ≠ 1000)

example : Spec.pre { temperature := 101, limit := 100 } ∧
          Spec.post { temperature := 101, limit := 100 }
                    { beepFrequency := 1000 } := by
  unfold Spec; decide
