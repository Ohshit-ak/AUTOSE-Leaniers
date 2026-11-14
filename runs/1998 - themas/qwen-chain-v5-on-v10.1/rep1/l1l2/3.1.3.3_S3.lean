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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := decide (x.temperature ≥ x.valid_min ∧ x.temperature ≤ x.valid_max),
    error_message := if decide (x.temperature ≥ x.valid_min ∧ x.temperature ≤ x.valid_max) = false then "Temperature out of valid range" else "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
