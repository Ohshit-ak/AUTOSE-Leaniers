import ContractForge
open ContractForge

-- 3.1.1.3.3/S2: The maximum number of concurrently running units shall be read from the initialization file and stored in the THEMAS system.

-- L0 spec

structure UnitDefinition where
  maxConcurrentUnits : Nat
  deriving DecidableEq, Repr

structure Input where
  initFile : String
  maxConcurrentUnits : Nat
  deriving DecidableEq, Repr

structure Output where
  maxConcurrentUnits : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.initFile ≠ ""
  post := fun i o => o.maxConcurrentUnits = i.maxConcurrentUnits

example : Spec.pre { initFile := "thermostat_init.txt", maxConcurrentUnits := 5 } ∧
          Spec.post { initFile := "thermostat_init.txt", maxConcurrentUnits := 5 }
                    { maxConcurrentUnits := 5 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { maxConcurrentUnits := x.maxConcurrentUnits }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
