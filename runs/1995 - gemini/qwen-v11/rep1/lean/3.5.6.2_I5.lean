import ContractForge
open ContractForge

-- 3.5.6.2/I5: hard limit switches - these switches will remove power from actuator when beyond soft limits; the software/electrical systems will allow movement off of hard limits
-- compiles: True · rejects_bad_example: True · checked: True

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
