import ContractForge
open ContractForge

-- 3.1.1.1.3/S1: The THEMAS system shall use the information contained in the initialization data file to determine which heating and cooling units are part of the THEMAS system.

-- L0 spec

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

-- IMPL: The system processes the initialization data to determine which units are heating or cooling units.
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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { units := x.initializationData.filter (fun u => u.type = "heating" ∨ u.type = "cooling") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
