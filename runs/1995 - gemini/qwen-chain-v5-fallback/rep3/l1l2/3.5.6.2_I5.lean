import ContractForge
open ContractForge

-- 3.5.6.2/I5: hard limit switches - these switches will remove power from actuator when beyond soft limits; the software/electrical systems will allow movement off of hard limits

-- L0 spec

structure Input where
  actuatorPower : Bool
  softLimitExceeded : Bool
  hardLimitExceeded : Bool
  deriving DecidableEq, Repr

structure Output where
  actuatorPower : Bool
  movementAllowed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.actuatorPower = true ∧ i.softLimitExceeded = false
  post := fun i o => (o.actuatorPower = false ↔ i.hardLimitExceeded = true) ∧
                     (o.movementAllowed = true ↔ i.softLimitExceeded = false ∧ i.hardLimitExceeded = false)

example : Spec.pre { actuatorPower := true, softLimitExceeded := false, hardLimitExceeded := false } ∧ Spec.post { actuatorPower := true, softLimitExceeded := false, hardLimitExceeded := false } { actuatorPower := true, movementAllowed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { actuatorPower := decide (¬ (x.hardLimitExceeded = true)),
    movementAllowed := decide (x.softLimitExceeded = false ∧ x.hardLimitExceeded = false) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
