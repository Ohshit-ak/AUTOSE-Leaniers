import ContractForge
open ContractForge

-- 3.2.2.1/S1: The TCS shall be capable of being interoperable with Predator and Outrider UAVs across the 5 levels of UAV interaction. [SSS011] The TCS shall have the capability to control and monitor multiple types of AVs. [SSS112] TCS shall notify the operator when AV performance parameters are out of limits. [SSS113] The TCS shall provide the capability to pass control of an AV to another TCS [SSS114], and receive control of an AV from another TCS [SSS115].
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  avType : String
  isOutrider : Bool
  performanceParams : List Nat
  deriving DecidableEq, Repr

structure Output where
  controlPassed : Bool
  controlReceived : Bool
  paramsWithinLimits : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.performanceParams.all (· ≤ 100)
  post := fun i o =>
    (o.controlPassed = true ↔ i.isOutrider) ∧
    (o.controlReceived = true ↔ ¬i.isOutrider) ∧
    (o.paramsWithinLimits = true ↔ i.performanceParams.all (· ≤ 100))

example : Spec.pre { avType := "Predator", isOutrider := true, performanceParams := [50, 60, 70] } ∧
          Spec.post { avType := "Predator", isOutrider := true, performanceParams := [50, 60, 70] }
                    { controlPassed := true, controlReceived := false, paramsWithinLimits := true } := by
  unfold Spec; decide
