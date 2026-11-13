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
  maxConcurrent : Nat
  heatingUnits : List HeatingUnit
  coolingUnits : List CoolingUnit
  deriving DecidableEq, Repr

structure Output where
  maxConcurrent : Nat
  heatingUnits : List HeatingUnit
  coolingUnits : List CoolingUnit
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.heatingUnits.Nodup ∧ i.coolingUnits.Nodup
  post := fun i o => o.maxConcurrent = i.maxConcurrent ∧
                     o.heatingUnits = i.heatingUnits ∧
                     o.coolingUnits = i.coolingUnits

example : Spec.pre { maxConcurrent := 5,
                     heatingUnits := [{ id := 1, status := true }],
                     coolingUnits := [{ id := 2, status := false }] } ∧
          Spec.post { maxConcurrent := 5,
                      heatingUnits := [{ id := 1, status := true }],
                      coolingUnits := [{ id := 2, status := false }] }
                    { maxConcurrent := 5,
                      heatingUnits := [{ id := 1, status := true }],
                      coolingUnits := [{ id := 2, status := false }] } := by
  unfold Spec; decide
