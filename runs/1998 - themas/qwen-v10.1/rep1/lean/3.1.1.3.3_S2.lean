import ContractForge
open ContractForge

-- 3.1.1.3.3/S2: The maximum number of concurrently running units shall be read from the initialization file and stored in the THEMAS system.
-- compiles: False · rejects_bad_example: None · checked: False

structure UnitDefinition where
  unitId : Nat
  maxConcurrent : Nat
  deriving DecidableEq, Repr

structure Input where
  units : List UnitDefinition
  deriving DecidableEq, Repr

structure Output where
  maxConcurrentUnits : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.units.Nodup
  post := fun i o => o.maxConcurrentUnits = i.units.maxConcurrent.max

example : Spec.pre { units := [{ unitId := 1, maxConcurrent := 5 },
                                { unitId := 2, maxConcurrent := 3 }] } ∧
          Spec.post { units := [{ unitId := 1, maxConcurrent := 5 },
                                { unitId := 2, maxConcurrent := 3 }] }
                    { maxConcurrentUnits := 5 } := by
  unfold Spec; decide
