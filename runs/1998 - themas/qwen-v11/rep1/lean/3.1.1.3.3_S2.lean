import ContractForge
open ContractForge

-- 3.1.1.3.3/S2: The maximum number of concurrently running units shall be read from the initialization file and stored in the THEMAS system.
-- compiles: True · rejects_bad_example: True · checked: True

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
