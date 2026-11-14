import ContractForge
open ContractForge

-- 3.1.1.3.3/S1: The maximum number of heating or cooling units that can run concurrently shall reside in an initialization file.
-- compiles: True · rejects_bad_example: True · checked: True

structure HeatingUnit where
  id : Nat
  status : Bool
  deriving DecidableEq, Repr

structure CoolingUnit where
  id : Nat
  status : Bool
  deriving DecidableEq, Repr

structure Input where
  maxHeatingUnits : Nat
  maxCoolingUnits : Nat
  heatingUnits : List HeatingUnit
  coolingUnits : List CoolingUnit
  deriving DecidableEq, Repr

structure Output where
  maxHeatingUnits : Nat
  maxCoolingUnits : Nat
  heatingUnits : List HeatingUnit
  coolingUnits : List CoolingUnit
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.maxHeatingUnits > 0 ∧ i.maxCoolingUnits > 0
  post := fun i o => o.maxHeatingUnits = i.maxHeatingUnits ∧
                     o.maxCoolingUnits = i.maxCoolingUnits ∧
                     o.heatingUnits = i.heatingUnits ∧
                     o.coolingUnits = i.coolingUnits

example : Spec.pre { maxHeatingUnits := 5, maxCoolingUnits := 3,
                     heatingUnits := [{ id := 1, status := true }],
                     coolingUnits := [{ id := 1, status := true }] } ∧
          Spec.post { maxHeatingUnits := 5, maxCoolingUnits := 3,
                      heatingUnits := [{ id := 1, status := true }],
                      coolingUnits := [{ id := 1, status := true }] }
                    { maxHeatingUnits := 5, maxCoolingUnits := 3,
                      heatingUnits := [{ id := 1, status := true }],
                      coolingUnits := [{ id := 1, status := true }] } := by
  unfold Spec; decide
