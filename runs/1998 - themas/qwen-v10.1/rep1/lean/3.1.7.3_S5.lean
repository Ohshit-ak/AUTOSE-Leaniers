import ContractForge
open ContractForge

-- 3.1.7.3/S5: If the system detects a temperature limit has been exceeded, this process shall output a continuous series of alternating 1000 Hz and 1500 Hz beeps on the supervisor's computer.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  temperatureLimitExceeded : Bool
  temperature : Nat
  limit : Nat
  deriving DecidableEq, Repr

structure Output where
  beepFrequency : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperatureLimitExceeded = true ∧ i.temperature ≥ i.limit
  post := fun i o => (o.beepFrequency = 1000 ↔ i.temperature % 2 = 0) ∧
                     (o.beepFrequency = 1500 ↔ i.temperature % 2 = 1)

example : Spec.pre { temperatureLimitExceeded := true, temperature := 100, limit := 90 } ∧
          Spec.post { temperatureLimitExceeded := true, temperature := 100, limit := 90 }
                    { beepFrequency := 1000 } := by
  unfold Spec; decide

example : Spec.pre { temperatureLimitExceeded := true, temperature := 101, limit := 90 } ∧
          Spec.post { temperatureLimitExceeded := true, temperature := 101, limit := 90 }
                    { beepFrequency := 1500 } := by
  unfold Spec; decide
