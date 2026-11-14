import ContractForge
open ContractForge

-- 3.1.1.1.3/S1: The THEMAS system shall use the information contained in the initialization data file to determine which heating and cooling units are part of the THEMAS system.
-- compiles: True · rejects_bad_example: True · checked: True

structure UnitDefinition where
  unitId : Nat
  type   : String
  deriving DecidableEq, Repr

structure Input where
  initializationData : List UnitDefinition
  deriving DecidableEq, Repr

structure Output where
  units : List UnitDefinition
  deriving DecidableEq, Repr

-- IMPL: The system reads the initialization data file and determines which units are heating or cooling units.

def Spec : Contract Input Output where
  pre  := fun i => i.initializationData.Nodup
  post := fun i o => o.units = i.initializationData.filter (fun u => u.type = "heating" ∨ u.type = "cooling")

example : Spec.pre { initializationData := [{ unitId := 1, type := "heating" },
                                             { unitId := 2, type := "cooling" },
                                             { unitId := 3, type := "heating" }] } ∧
          Spec.post { initializationData := [{ unitId := 1, type := "heating" },
                                              { unitId := 2, type := "cooling" },
                                              { unitId := 3, type := "heating" }] }
                    { units := [{ unitId := 1, type := "heating" },
                                { unitId := 2, type := "cooling" },
                                { unitId := 3, type := "heating" }] } := by
  unfold Spec; decide
