import ContractForge
open ContractForge

-- 3.1.3.3/S1: Two types of temperature data shall be recognized from the thermostats: 1) the temperature setting and 2) the current temperature.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  setting : Nat
  current : Nat
  deriving DecidableEq, Repr

structure Output where
  settingValid : Bool
  currentValid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.settingValid = true ∧ o.currentValid = true

example : Spec.pre { setting := 23, current := 22 } ∧
          Spec.post { setting := 23, current := 22 }
                    { settingValid := true, currentValid := true } := by
  unfold Spec; decide
