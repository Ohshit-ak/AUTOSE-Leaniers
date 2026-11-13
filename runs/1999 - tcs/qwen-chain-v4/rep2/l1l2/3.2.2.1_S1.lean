import ContractForge
open ContractForge

-- 3.2.2.1/S1: The TCS shall be capable of being interoperable with Predator and Outrider UAVs across the 5 levels of UAV interaction. [SSS011] The TCS shall have the capability to control and monitor multiple types of AVs. [SSS112] TCS shall notify the operator when AV performance parameters are out of limits. [SSS113] The TCS shall provide the capability to pass control of an AV to another TCS [SSS114], and receive control of an AV from another TCS [SSS115].

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { controlPassed := x.isOutrider,
    controlReceived := ¬x.isOutrider,
    paramsWithinLimits := x.performanceParams.all (· ≤ 100) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
