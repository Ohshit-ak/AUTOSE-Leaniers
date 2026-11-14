import ContractForge
open ContractForge

-- 1.2.2/S4: Although developed as a total package, the TCS will be scaleable to meet the user's requirements for deployment.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  deploymentSize : Nat
  numControllers  : Nat
  numSensors      : Nat
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
