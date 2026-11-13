import ContractForge
open ContractForge

-- 3.1.3.3/S3: A current temperature value that is received from an individual thermostat shall be compared to the valid temperature range values.

-- L0 spec

structure Input where
  temperature : Nat
  valid_min   : Nat
  valid_max   : Nat
  deriving DecidableEq, Repr

structure Output where
  valid         : Bool
  error_message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature < 10000 && i.valid_min < 10000 && i.valid_max < 10000
  post := fun i o => (o.valid = true ↔ i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max) ∧
                     (o.valid = false → o.error_message ≠ "")

example : Spec.pre { temperature := 25, valid_min := 0, valid_max := 50 } ∧
          Spec.post { temperature := 25, valid_min := 0, valid_max := 50 }
                    { valid := true, error_message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  valid         : Bool
  error_message : String
  deriving DecidableEq, Repr

def TemperatureCheckContract : Contract Input Mid where
  pre  := fun i => i.temperature < 10000 && i.valid_min < 10000 && i.valid_max < 10000
  post := fun i m => (m.valid = true ↔ i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max) ∧
                     (m.valid = false → m.error_message ≠ "")

def ErrorHandlingContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.valid = true ↔ m.valid) ∧ (o.error_message = m.error_message)
