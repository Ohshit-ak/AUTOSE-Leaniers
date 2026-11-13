import ContractForge
open ContractForge

-- 3.1.3.3/S4: If the current temperature value is strictly less than the lower value of the valid temperature range or if the received temperature value is strictly greater than the upper value of the valid temperature range, then the THEMAS system shall identify the current temperature value as an invalid temperature and shall output an invalid temperature status.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  currentTemp : Nat
  validRange  : { lower : Nat, upper : Nat } deriving DecidableEq, Repr
  deriving DecidableEq, Repr

structure Output where
  invalidTemp : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.invalidTemp = true ↔
    (i.currentTemp < i.validRange.lower ∨ i.currentTemp > i.validRange.upper))

example : Spec.pre { currentTemp := 10, validRange := { lower := 15, upper := 25 } } ∧
          Spec.post { currentTemp := 10, validRange := { lower := 15, upper := 25 } }
                    { invalidTemp := true } := by
  unfold Spec; decide
