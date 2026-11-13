import ContractForge
open ContractForge

-- 3.5.6.2/I5: hard limit switches - these switches will remove power from actuator when beyond soft limits; the software/electrical systems will allow movement off of hard limits

-- L0 spec

structure Input where
  actuatorPosition : Nat
  softLimit        : Nat
  hardLimit        : Nat
  deriving DecidableEq, Repr

structure Output where
  actuatorPower    : Bool
  actuatorMoving   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.actuatorPosition ≤ i.softLimit
  post := fun i o => (o.actuatorPower = false ↔ i.actuatorPosition > i.hardLimit) ∧
                     (o.actuatorMoving = true ↔ i.actuatorPosition ≤ i.hardLimit)

example : Spec.pre { actuatorPosition := 5, softLimit := 10, hardLimit := 8 } ∧ Spec.post { actuatorPosition := 5, softLimit := 10, hardLimit := 8 } { actuatorPower := true, actuatorMoving := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { actuatorPower := decide (x.actuatorPosition > x.hardLimit),
    actuatorMoving := decide (x.actuatorPosition ≤ x.hardLimit) }
