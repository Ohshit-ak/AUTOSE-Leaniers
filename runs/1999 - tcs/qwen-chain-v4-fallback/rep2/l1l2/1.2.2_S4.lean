import ContractForge
open ContractForge

-- 1.2.2/S4: Although developed as a total package, the TCS will be scaleable to meet the user's requirements for deployment.

-- L0 spec

structure Input where
  deploymentSize : Nat
  numControllers : Nat
  numSensors    : Nat
  deriving DecidableEq, Repr

structure Output where
  deploymentSize : Nat
  numControllers : Nat
  numSensors    : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.deploymentSize > 0
  post := fun i o => o.deploymentSize = i.deploymentSize ∧
                     (o.numControllers ≥ i.deploymentSize / 10 ∧
                      o.numSensors ≥ i.deploymentSize / 5)

example : Spec.pre { deploymentSize := 50, numControllers := 6, numSensors := 10 } ∧
          Spec.post { deploymentSize := 50, numControllers := 6, numSensors := 10 }
                    { deploymentSize := 50, numControllers := 6, numSensors := 10 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deploymentSize := x.deploymentSize,
    numControllers := max (x.deploymentSize / 10) 1,
    numSensors := max (x.deploymentSize / 5) 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
