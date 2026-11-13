import ContractForge
open ContractForge

-- 3.5.6.2/I5: hard limit switches - these switches will remove power from actuator when beyond soft limits; the software/electrical systems will allow movement off of hard limits
-- compiles: True · rejects_bad_example: None · checked: True

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
