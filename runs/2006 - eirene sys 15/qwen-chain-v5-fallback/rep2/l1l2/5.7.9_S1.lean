import ContractForge
open ContractForge

-- 5.7.9/S1: The "Subscriber Identity Module" (SIM card) shall be physically integrated with the radio set and shall not be able to be removed except by maintenance staff.

-- L0 spec

structure Input where
  simIntegrated : Bool
  maintenanceStaff : Bool
  deriving DecidableEq, Repr

structure Output where
  simIntegrated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.simIntegrated = true ∧ i.maintenanceStaff = false
  post := fun i o => o.simIntegrated = i.simIntegrated ∧
                     (o.simIntegrated = false ↔ i.maintenanceStaff = true)

example : Spec.pre { simIntegrated := true, maintenanceStaff := false } ∧
          Spec.post { simIntegrated := true, maintenanceStaff := false }
                    { simIntegrated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { simIntegrated := x.simIntegrated }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
