import ContractForge
open ContractForge

-- 2/I8: 2.8 System Security and Availability: Security of OM data includes the protection of data from corruption and access by unauthorized individuals, as well as the protection of the actual systems supporting OM from sabotage or other failure. A plan must be established for continuing activities when systems supporting OM are unavailable.

-- L0 spec

structure Input where
  data : String
  systemStatus : String
  deriving DecidableEq, Repr

structure Output where
  dataProtected : Bool
  systemAvailable : Bool
  contingencyPlan : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ "" ∧ i.systemStatus ≠ ""
  post := fun i o => o.dataProtected = true ∧
                     o.systemAvailable = true ∧
                     o.contingencyPlan = true

example : Spec.pre { data := "OM data", systemStatus := "active" } ∧
          Spec.post { data := "OM data", systemStatus := "active" }
                    { dataProtected := true, systemAvailable := true, contingencyPlan := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { dataProtected := true, systemAvailable := true, contingencyPlan := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
